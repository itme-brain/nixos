{ pkgs, lib, desktop, me, ... }:

{ system.stateVersion = "22.11";
  environment.defaultPackages = [ ];

# Nix
  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    settings = {
      auto-optimise-store = true;
    };
    gc = {
      automatics = true;
      options = "weekly";
    };
  };
  environment.systemPackages = with pkgs; [ nix-init pavucontrol ];

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
  users.users.${me} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "home-manager" "input" "video" "audio" "kvm" "libvirtd" "docker" ];
    openssh.authorizedKeys.keyFiles = [ /etc/ssh/authorized_keys ];
  };

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
        "0 0 * * *  ${me}  /home/${me}/Documents/scripts/lnbackup_script.sh"
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
    hostName = desktop;
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
    settings.PasswordAuthentication = false;
  };
}
