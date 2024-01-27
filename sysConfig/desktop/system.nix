{ pkgs, lib, ... }:

{ system.stateVersion = "22.11";

# Nix
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "bryan" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
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
    monocraft
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

# Users
  users.users = import ./user;

  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

# System Services
  services = {
    trezord.enable = true;

    cron = {
      enable = true;
      systemCronJobs = [
      ];
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
