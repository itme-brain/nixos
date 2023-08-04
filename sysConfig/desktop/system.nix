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
  environment.systemPackages = with pkgs; [ nix-init pavucontrol ];

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

# Users
  users.users.bryan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "home-manager" "input" "video" "audio" "kvm" "libvirtd" "docker" ];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDl4895aB9P5p/lp8Hq5rHun4clvhyTSHFi3U2d6OOBoW5Fm+VcQnW/xbjmCBsXk5BdiowsBxQhwnzdfz/KJL7J5RobomUEaVRwb9UwT88eJveLp14BG8j2J3SjfyhrCX+4jkPx0bPQk1HGcuYY+tPEXf1q/ps88Dhu0CARBIzYQOTYY6b1qWzxpDoFZGHjKG8g5iY6FIu65yKKvvVy1f8IgZ3l3IpwBWVamxgkTcYY0QYSrmzo1n7TXxwrWbvenAqBsQ0cBPs+gVa3uIr+1TJl0Az5SElBVGu3LvUdlk58trtPUj6TQR3YUkg7Vjll7WHOdqhux5ZQNhjkOsHerf0Tw86e6cEzgeTuIbQHIb0LcsUunwKcuh2+au7RO599cvHn0+xZE5MZBxloDDaJ3JsiliM8kyPP/U3ERj03cWLW7BqbT+sfjAOl21RCzk0iQxk1wt/8VmtCr9Adv7IyrtaYvf/bwRP+g+9ldmzKGt8Mdb605uVzZ70H/LLm17f40Te+QHaex5by/6p6cuwEEZtgIg53Wpglu0rA6UxrBfQEHKl/Jt3FLeE0mnEyYkkR2MnHNtyWRIXtuqYZMAm2Ub1pFHH7jQV1gGiDVTw6a2eIwK21a/hXtRjFUpFd1nB1n+KNfJBE4zT3wm3Ud7mKw/6rWnoRyhYZvGXkFdp+iEs49Q=="
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBK2ROz7EVvE+nzF5k9EYZ2v3JhBzk058uh3QJTzcG4t70fkZgh9y56AOx26eXlKQWuuV05e8EkWRuVI8gfA2ROI="
    ];
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
        "0 0 * * *  bryan  /home/bryan/Documents/scripts/lnbackup_script.sh"
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
      X11Forwarding = true;
      PasswordAuthentication = false;
    };
  };
}
