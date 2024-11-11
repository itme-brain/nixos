{ pkgs, lib, config, ... }:

{
  system.stateVersion = "23.11";
  boot.isContainer = true;

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

  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

  time = {
    timeZone = "America/New_York";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  networking = {
    hostName = "wsl";
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

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
