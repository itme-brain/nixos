{ pkgs, lib, config, ... }:

{ system.stateVersion = "25.11";

  imports = [ ../../modules ];

  modules.system = {
    nginx.enable = true;
    forgejo.enable = true;
    frigate.enable = true;
    immich.enable = true;
    # bitcoin = {
    #   enable = true;
    #   electrum.enable = true;
    #   clightning.enable = true;
    # };

    backup = {
      enable = true;
      recipients = [
       "${config.user.keys.age.yubikey}"
       "${config.machines.keys.desktop.ssh}"
      ];
      paths = [ "/root/.config/rclone" ];
      destination = "gdrive:backups/server";
      schedule = "daily";
      keepLast = 2;
    };
  };

  users.users = {
    ${config.user.name} = {
      isNormalUser = true;
      extraGroups = config.user.groups;
      openssh.authorizedKeys.keys = [
        "${config.machines.keys.desktop.ssh}"
      ];
    };
  };

  nix = {
    channel.enable = false;
    package = pkgs.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "${config.user.name}" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  boot.loader = {
    timeout = 3;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      configurationLimit = 5;
      splashImage = null;
    };

    efi = {
      canTouchEfiVariables = true;
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    vim
    htop
  ];

  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

  time = {
    timeZone = "America/New_York";
    hardwareClockInLocalTime = true;
  };

  services.timesyncd = lib.mkDefault {
    enable = true;
    servers = [
      "0.pool.ntp.org"
      "1.pool.ntp.org"
      "2.pool.ntp.org"
      "3.pool.ntp.org"
    ];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  console.font = "Lat2-Terminus16";

  networking = {
    hostName = "server";
    useDHCP = false;
    interfaces.enp2s0f0 = {
      ipv4.addresses = [{
        address = "192.168.0.154";
        prefixLength = 24;
      }];
    };
    # Camera network - isolated, no gateway
    interfaces.enp2s0f1 = {
      ipv4.addresses = [{
        address = "192.168.1.1";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.0.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 53 67 ];  # DNS + DHCP
      extraCommands = ''
        # Block specific camera MACs from forwarding (instant DROP, no timeouts)
        # Add each camera MAC here as you set them up
        iptables -A FORWARD -m mac --mac-source 00:1f:54:c2:d1:b1 -j DROP  # parking_lot
        iptables -A FORWARD -m mac --mac-source 00:1f:54:b2:9b:1d -j DROP  # living_room/kitchen
      '';
      extraStopCommands = ''
        iptables -D FORWARD -m mac --mac-source 00:1f:54:c2:d1:b1 -j DROP || true
        iptables -D FORWARD -m mac --mac-source 00:1f:54:b2:9b:1d -j DROP || true
      '';
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      # All *.ramos.codes subdomains -> local server
      address = "/.ramos.codes/192.168.0.154";
      # Except www, http, https and bare domain -> forward to upstream
      server = [
        "/www.ramos.codes/1.1.1.1"
        "/http.ramos.codes/1.1.1.1"
        "/https.ramos.codes/1.1.1.1"
        "/ramos.codes/1.1.1.1"
        "1.1.1.1"
        "8.8.8.8"
      ];
      cache-size = 1000;

      # Camera network DHCP (isolated - no gateway = no internet)
      interface = "enp2s0f1";
      bind-interfaces = true;
      dhcp-range = "192.168.1.100,192.168.1.200,24h";

      # Static DHCP reservations for cameras
      dhcp-host = [
        "00:1f:54:c2:d1:b1,192.168.1.194,parking_lot"
        "00:1f:54:b2:9b:1d,192.168.1.147,living_room_kitchen"
      ];
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
  };

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    settings = {
      X11Forwarding = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
