{ pkgs, lib, config, ... }:

{
  system.stateVersion = "23.11";
  boot.isContainer = true;

# Users
  users.users = {
    ${config.user.name} = {
      isNormalUser = true;
      extraGroups = config.user.groups;
      openssh.authorizedKeys.keys = [ 
        "${config.user.keys.ssh.primary}" 
        "${config.user.keys.ssh.windows}" 
      ];
    };
  };

# Nix
  nix = {
    channel.enable = false;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "${config.user.name}" ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

# Sudo Options
  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

# Locale
  time = {
    timeZone = "America/New_York";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

# Networking
  networking = {
    hostName = "wsl";
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

# System Services
  services = {
    openssh = {
      enable = true;
      startWhenNeeded = true;
      settings = {
        X11Forwarding = false;
        PasswordAuthentication = false;
      };
    };
    timesyncd = lib.mkDefault {
      enable = true;
      servers = [
        "time.windows.com"
      ];
    };
  };
}
