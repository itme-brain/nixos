{ pkgs, lib, config, ... }:
{
  system.stateVersion = "23.05";
  environment.defaultPackages = [ ];

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

  users.users.bryan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "home-manager" "input" "video" "audio" "kvm" "libvirtd" "docker" ]; 
  };

  security.sudo.wheelNeedsPassword = false;

# GUI
  programs = {
    sway = {
      enable = true;

      extraPackages = with pkgs; [
        rofi-wayland
        grim
        slurp
        wl-clipboard

        xdg-utils

        fontconfig
        qogir-icon-theme
        emote

        pavucontrol
      ];

      extraSessionCommands = ''
        if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
          exec sway 
        fi
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
    };
    xwayland.enable = true;
    xdg.portal.wlr.enable = true;
    
    gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
  };

  services.pipewire = {
    enable = true;
    audio.enable = true;

    wireplumber.enable = true;

    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };
    
  fonts = {
    fonts = with pkgs; [
      terminus_font
      nerdfonts
      
      noto-fonts
      noto-fonts-cjk
      
      emojione
    ];
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

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
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

  # Networking
  networking = {
    hostName = "socrates";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    firewall.enable = true;
  };
}
