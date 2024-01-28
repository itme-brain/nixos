{ pkgs, lib, config, ... }:

{ system.stateVersion = "22.11";

# Users
  users.users = {
    ${config.user.name} = config.user;
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

  environment.systemPackages = with pkgs; [
    pavucontrol

    nix-init
    nix-prefetch-git
  ];

# DE
  programs.sway = {
    enable = true;
    package = null;
  };

# Fonts
  fonts.packages = with pkgs; [
    terminus_font
    nerdfonts
  ];

# Audio
  services.pipewire = {
    enable = true;
    audio.enable = true;

    wireplumber.enable = true;

    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

# Sudo Options
  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

# System Services
  services = {
    trezord.enable = true;

    cron = {
      enable = true;
      systemCronJobs = [];
    };
  };

# Locale
  time = {
    timeZone = "America/New_York";
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
    hostName = "socrates";
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
