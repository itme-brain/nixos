{ pkgs, lib, config, ... }:

{ system.stateVersion = "23.11";

  users.users = {
    ${config.user.name} = {
      isNormalUser = true;
      extraGroups = config.user.groups
        ++ [ "video" "audio" "kvm" "libvirtd" "dialout" ];
      openssh.authorizedKeys.keys = [ "${config.user.keys.ssh.android}" ];
    };
  };

  nix = {
    channel.enable = false;
    package = pkgs.nixFlakes;
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

  environment.systemPackages = with pkgs; [
    vim
    git
    usbutils
  ];

  fonts.packages = with pkgs; [
    terminus_font
    terminus-nerdfont
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
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  services = {
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
        PasswordAuthentication = true;
      };
    };
  };
}
