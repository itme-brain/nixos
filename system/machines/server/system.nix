{ pkgs, lib, config, ... }:

{ system.stateVersion = "25.11";

  imports = [ ./modules ];

  modules.system.sops.enable = true;

  # Camera RTSP credentials (used by frigate/go2rtc)
  sops.secrets = let
    cameras = { sopsFile = ../../../secrets/system/cameras.yaml; };
    llama = { sopsFile = ../../../secrets/system/llama.yaml; };
  in {
    "RTSP_USER" = cameras;
    "RTSP_PASS" = cameras;
    "LLAMA_API_KEY" = llama // { owner = config.user.name; };
  };

  # API key auth for ai.ramos.codes — nginx validates Bearer token against sops secret
  sops.templates."nginx-ai-auth.conf" = {
    content = ''
      if ($api_key != "${config.sops.placeholder."LLAMA_API_KEY"}") {
        return 401 '{"error": "Invalid API key"}';
      }
    '';
    owner = "nginx";
  };

  # MCP endpoint auth — validates X-API-Key header
  sops.templates."nginx-mcp-auth.conf" = {
    content = ''
      if ($http_x_api_key != "${config.sops.placeholder."LLAMA_API_KEY"}") {
        return 401 '{"error": "Unauthorized"}';
      }
    '';
    owner = "nginx";
  };

  modules.system = {
    nginx = {
      enable = true;
    };
    sandpack.enable = false;
    forgejo.enable = true;
    frigate.enable = true;
    immich.enable = true;
    webdav.enable = false;
    wstunnel.enable = true;
    wireguard = {
      enable = true;
      peers = [
        {
          publicKey = "HRFsVXn3jeqKQLQIl0cB6KC/qia7M1gQf2lqG5HDxF8=";
          allowedIPs = [ "10.8.0.2/32" ];
        }
        {
          publicKey = "eY2JTwuvzLLVnyhUTop0I+7qO2swFSjo12So4Yzkamk=";
          allowedIPs = [ "10.8.0.3/32" ];
        }
      ];
    };
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
      efiInstallAsRemovable = true;  # HP Z230 UEFI ignores custom boot entries
      configurationLimit = 5;
      splashImage = null;
    };

    efi = {
      canTouchEfiVariables = false;  # Not needed with efiInstallAsRemovable
      efiSysMountPoint = "/boot";
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    vim
    htop
    dmidecode
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

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking = {
    hostName = "server";
    useDHCP = false;
    nat = {
      enable = true;
      internalInterfaces = [ "enp2s0f1" ];
      externalInterface = "enp2s0f0";
    };
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
      # extraCommands = ''
      #   # Block camera MACs from forwarding (instant DROP, no timeouts)
      #   iptables -A FORWARD -m mac --mac-source 00:1f:54:c2:d1:b1 -j DROP  # cam4
      #   iptables -A FORWARD -m mac --mac-source 00:1f:54:b2:9b:1d -j DROP  # cam2/cam3
      #   iptables -A FORWARD -m mac --mac-source 00:1f:54:a9:81:d1 -j DROP  # cam1
      # '';
      # extraStopCommands = ''
      #   iptables -D FORWARD -m mac --mac-source 00:1f:54:c2:d1:b1 -j DROP || true
      #   iptables -D FORWARD -m mac --mac-source 00:1f:54:b2:9b:1d -j DROP || true
      #   iptables -D FORWARD -m mac --mac-source 00:1f:54:a9:81:d1 -j DROP || true
      # '';
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
      interface = [ "enp2s0f1" "wg0" ];
      bind-interfaces = true;
      dhcp-range = "192.168.1.100,192.168.1.200,24h";

      # Static DHCP reservations for cameras
      dhcp-host = [
        "00:1f:54:c2:d1:b1,192.168.1.194,cam4"
        "00:1f:54:b2:9b:1d,192.168.1.147,cam2"
        "00:1f:54:a9:81:d1,192.168.1.167,cam1"
      ];
    };
  };

  systemd.services.dnsmasq = {
    after = [ "wireguard-wg0.service" ];
    wants = [ "wireguard-wg0.service" ];
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    ignoreIP = [
      "127.0.0.1/8"
      "192.168.0.0/24"
      "10.8.0.0/24"
    ];
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
