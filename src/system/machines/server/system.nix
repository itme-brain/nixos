{ pkgs, lib, config, ... }:

{ system.stateVersion = "23.11";

  imports = [
    ../modules
  ];

  modules = {
    bitcoin = {
      enable = true;
      clightning = true;
      electrs = true;
      sparrow-server = true;
    };
  };

# Users
  users.users = {
    ${config.user.name} = {
      isNormalUser = true;
      extraGroups = config.user.groups;
      openssh.authorizedKeys.keys = config.user.sshKeys;
    };
  };

# Nix
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

# Bootloader
  boot.loader = {
    timeout = null;
    grub = {
      enable = true;
      useOSProber = true;
      devices = [ "nodev" ];
      efiSupport = true;
      configurationLimit = 5;
    };

    efi = {
      canTouchEfiVariables = true;
    };
  };

# Fonts
  fonts.packages = with pkgs; [
    terminus_font
    terminus-nerdfont
  ];

# Sudo Options
  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

# Locale
  time = {
    timeZone = "America/New_York";
    hardwareClockInLocalTime = true;
  };

  services.timesyncd = {
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

# Networking
  networking = {
    hostName = "archimedes";
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
      PasswordAuthentication = false;
    };
  };
}
