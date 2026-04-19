{ pkgs, lib, config, ... }:

{
  system.stateVersion = "25.11";

  imports = [ ./modules ];

  modules.system.kiosk = {
    enable = true;
    user = config.user.name;
    url = "https://www.cineby.sc";
  };

  users.users.${config.user.name} = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    openssh.authorizedKeys.keys = [
      "${config.machines.keys.desktop.ssh}"
      "${config.machines.keys.windows.ssh}"
    ];
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

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
  ];

  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

  time.timeZone = "America/New_York";

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
  console.font = "Lat2-Terminus16";

  networking = {
    hostName = "tv";
    useDHCP = false;
    interfaces.end0 = {
      ipv4.addresses = [{
        address = "192.168.0.176";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.0.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
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