{ pkgs, lib, config, ... }:

let
  gpgEnabled = lib.any
    (user: user.modules.user.security.gpg.enable or false)
    (lib.attrValues config.home-manager.users);

in
{ system.stateVersion = "23.11";

  modules.system.sops.enable = true;

  # WiFi secrets
  sops.secrets = let wifi = { sopsFile = ../../../secrets/system/wifi.yaml; }; in {
    "WIFI_HOME_SSID" = wifi;
    "WIFI_HOME_PSK" = wifi;
    "WIFI_CAMS_SSID" = wifi;
    "WIFI_CAMS_PSK" = wifi;
  };

  sops.templates."wifi-env".content = ''
    WIFI_HOME_SSID=${config.sops.placeholder."WIFI_HOME_SSID"}
    WIFI_HOME_PSK=${config.sops.placeholder."WIFI_HOME_PSK"}
    WIFI_CAMS_SSID=${config.sops.placeholder."WIFI_CAMS_SSID"}
    WIFI_CAMS_PSK=${config.sops.placeholder."WIFI_CAMS_PSK"}
  '';

  users.users = {
    ${config.user.name} = {
      isNormalUser = true;
      extraGroups = config.user.groups
        ++ [ "video" "audio" "kvm" "libvirtd" "dialout" ];
      openssh.authorizedKeys.keys = [ "${config.user.keys.ssh.graphone}" ];
    };
  };

  nix = {
    channel.enable = false;
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-going = true
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "${config.user.name}" ];
      substitute = true;
      max-jobs = "auto";
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
      #memtest86.enable = true;
    };

    efi = {
      canTouchEfiVariables = true;
    };
    #timeout = null;
  };

  environment = {
    systemPackages = with pkgs; [
      vim
      git
      usbutils
    ];
    pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.terminess-ttf
  ];

  security = {
    sudo = {
      wheelNeedsPassword = false;
      execWheelOnly = true;
    };
    polkit.enable = true;
  };

  time = {
    timeZone = "America/New_York";
    hardwareClockInLocalTime = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  networking = {
    hostName = "desktop";
    useDHCP = lib.mkDefault true;
    networkmanager = {
      enable = true;
      ensureProfiles = {
        environmentFiles = [ config.sops.templates."wifi-env".path ];
        profiles.wifi = {
          connection = {
            id = "$WIFI_HOME_SSID";
            type = "wifi";
            interface-name = "wlo1";
            autoconnect = false;  # Manual connection via nmcli
          };
          wifi = {
            ssid = "$WIFI_HOME_SSID";
            mode = "infrastructure";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$WIFI_HOME_PSK";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
        profiles.cams = {
          connection = {
            id = "$WIFI_CAMS_SSID";
            type = "wifi";
            interface-name = "wlo1";
            autoconnect = false;
          };
          wifi = {
            ssid = "$WIFI_CAMS_SSID";
            mode = "infrastructure";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$WIFI_CAMS_PSK";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
      };
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      # Explicit subdomains -> local server
      address = [
        "/git.ramos.codes/192.168.0.154"
        "/ln.ramos.codes/192.168.0.154"
        "/photos.ramos.codes/192.168.0.154"
        "/test.ramos.codes/192.168.0.154"
        "/electrum.ramos.codes/192.168.0.154"
        "/immich.ramos.codes/192.168.0.154"
        "/forgejo.ramos.codes/192.168.0.154"
        "/frigate.ramos.codes/192.168.0.154"
      ];
      server = [ "192.168.0.1" ];
    };
  };

  services = {
    pcscd.enable = gpgEnabled;
    timesyncd = lib.mkDefault {
      enable = true;
      servers = [
        "0.pool.ntp.org"
        "1.pool.ntp.org"
        "2.pool.ntp.org"
        "3.pool.ntp.org"
      ];
    };
    pipewire = {
      enable = true;
      audio.enable = true;

      wireplumber.enable = true;

      pulse.enable = true;
      jack.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };
    openssh = {
      enable = true;
      startWhenNeeded = false;
      settings = {
        X11Forwarding = false;
        PasswordAuthentication = false;
      };
    };
  };
}
