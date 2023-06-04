{ pkgs, lib, config, ... }:
{
  system.stateVersion = "23.05";
  environment.defaultPackages = [ ];

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    settings = {
      allowed-users = "bryan";
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

  boot = {
    loader = {
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
#    extraModprobeConfig = ''
#      options vfio-pci ids=10de:1f82,10de:10fa
#    '';
  };

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
    };

    xwayland = { 
      enable = true;
    };
    
    bash = {
      enable = true;
      enableCompletion = true;
      enableLsColors = true;
      blesh.enable = true;
      
      shellInit = ''
        if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
          exec sway 
        fi

        if [ "$XDG_CURRENT_DESKTOP" = "sway" ] ; then
            # https://github.com/swaywm/sway/issues/595
            export _JAVA_AWT_WM_NONREPARENTING=1
        fi

        export EDITOR=nvim
        eval "$(direnv hook bash)"
      '';

      promptInit = ''
        # Check if the current shell is an SSH session
        is_ssh_session() {
          if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
            return 0
          else
            return 1
          fi
        }

        # PS1 Config
        function set_ps1_prompt() {
          local git_branch=""
          local flake_icon=""
          local cur_dir=""

          # Check if we're inside a git repository
          if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            # If we are, get the current branch name
            git_branch="$(git symbolic-ref --short HEAD 2>/dev/null)"

            # If the command failed, we're in a detached HEAD state, so get the short SHA
            if [ $? -ne 0 ]; then
              git_branch="$(git rev-parse --short HEAD 2>/dev/null)"
            fi

            # Wrap the branch name and : in braces and color it red
            git_branch=" \[\033[01;31m\]$git_branch󰘬:\[\033[00m\]"

            # Check if flake.nix file exists
            if [ -f "$(git rev-parse --show-toplevel)/flake.nix" ]; then
                # If it exists, set the flake icon and color it blue
                flake_icon="\[\033[01;34m\] \[\033[00m\]"
            fi

            # Get the root directory of the git repository
            git_root="$(basename "$(git rev-parse --show-toplevel)")"

            # Get the current directory relative to the Git root
            cur_dir=$(realpath --relative-to=$(git rev-parse --show-toplevel) .)
            if [ "$cur_dir" == "." ]; then
              cur_dir="\[\033[01;34m\] $git_root\[\033[00m\]"
            else
              cur_dir="\[\033[01;34m\] $git_root/$cur_dir\[\033[00m\]"
            fi
          else
            # If not in a Git repository, just show the normal path
            cur_dir="\[\033[01;34m\]\w\[\033[00m\]"
          fi

          if [ -n "${IN_NIX_SHELL:+x}" ]; then
            PS1="$cur_dir\n$flake_icon\[\033[01;32m\]nixShell>$git_branch\[\033[00m\]"
          else
            if ! is_ssh_session; then
              PS1="\n$cur_dir\n$flake_icon\[\033[01;32m\]>$git_branch\[\033[00m\]"
            else
              PS1="\n\[\033[01;34m\]\w\[\033[00m\]\n\[\033[01;32m\]\u@\h:\[\033[00m\] "
            fi
          fi
          unset flake_icon
        }

        PROMPT_COMMAND="set_ps1_prompt; $PROMPT_COMMAND"
      '';

      shellAliases = {
        ls = "lsd";
        hmup="home-manager switch --flake '$HOME/Documents/projects/nixos#bryan'";
        nixup="sudo nixos-rebuild switch --flake '$HOME/Documents/projects/nixos#socrates'";
      };
    };

    gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    git.enable = true;
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

  xdg.portal.wlr.enable = true;
  
  services.pipewire = {
    enable = true;
    audio.enable = true;

    wireplumber.enable = true;

    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

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

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      ovmf.enable = true;
    };
  };
}
