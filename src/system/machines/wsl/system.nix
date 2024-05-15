{ pkgs, lib, config, ... }:

{ system.stateVersion = "23.11";

# Users
  users.users = {
    ${config.user.name} = {
      isNormalUser = true;
      extraGroups = config.user.groups;
      openssh.authorizedKeys.keys = [ "${config.user.keys.ssh.primary}" ];
    };
  };
  boot.isContainer = true;

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

# Sudo Options
  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

# System Services
  services = {
    cron = {
      enable = true;
      systemCronJobs = [];
    };
  };

# Locale
  time = {
    timeZone = "America/New_York";
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

# Networking
  networking = {
    useDHCP = lib.mkDefault true;
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
