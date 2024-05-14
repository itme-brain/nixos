{ pkgs, lib, config, ... }:

{ system.stateVersion = "23.11";

  imports = [ ../../modules ];

  modules = {
    system = {
      bitcoin.enable = true;
    };
  };

  users.users = {
    ${config.user.name} = {
      isNormalUser = true;
      extraGroups = config.user.groups;
      openssh.authorizedKeys.keys = [ "${config.user.sshKeys.key1}" ];
    };
  };

  nix = {
    channel.enable = false;
    package = pkgs.nixFlakes;
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
    timeout = null;
    grub = {
      enable = true;
      useOSProber = true;
      devices = [ "nodev" ];
      efiSupport = true;
      configurationLimit = 3;
      splashImage = null;
    };

    efi = {
      canTouchEfiVariables = true;
    };
  };

  fonts.packages = with pkgs; [
    terminus_font
    terminus-nerdfont
  ];

  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

  time = {
    timeZone = "America/New_York";
    hardwareClockInLocalTime = false;
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

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  networking = {
    hostName = "server";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    settings = {
      X11Forwarding = false;
      PasswordAuthentication = true;
    };
  };
}
