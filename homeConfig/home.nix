{ config, pkgs, ... }:

{
  programs.home-manager.enable = true; # Leave this set to true.

  home = { 
    username = "bryan";
    homeDirectory = "/home/bryan";
    stateVersion = "22.11"; # Do not edit this variable
  };

  home.packages = with pkgs; [
    firefox
    (tor-browser-bundle-bin.override {
      useHardenedMalloc = false; # Nix specific bug in tor browser requires disabling useHardenedMalloc
    })

    spotify
    discord

    alacritty
    ranger
    imv
    gimp

    android-studio

    syncthing
    rsync
    wget
    curl
    btop
    pciutils
    tree
    git
    openssh
    unzip
    lsd
    fping
    calc

    bash-completion
    nodePackages."@tailwindcss/language-server"
    pkg-config
    docker
    
    trezor-suite
    trezorctl
    bisq-desktop

    keepassxc
    neofetch    

    qogir-icon-theme
  ];

# PROGRAM CONFIGS

# NEOVIM
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs; [
      vimPlugins.nvim-treesitter.withAllGrammars
    ];
  };

# SERVICES

# GPG SSH AGENT 
  home.sessionVariables = {
    SSH_AUTH_SOCK = "${config.xdg.dataHome}/gnupg/S.gpg-agent.ssh";
    };
 

# DOTFILE SYMLINKS
  home.file = {
    ".config/home-manager/home.nix".source = ./home.nix; # Do not remove or edit this symlink
    
    ".bashrc".source = ./dotfiles/bash/bashrc;
    ".bash_profile".source = ./dotfiles/bash/bash_profile;

    ".config/sway/config".source = ./dotfiles/sway/config;
    ".config/sway/wallpapers".source = ./dotfiles/sway/wallpapers;
    
    ".config/rofi/config.rasi".source = ./dotfiles/rofi/config.rasi;

    ".config/alacritty".source = ./dotfiles/alacritty;
    ".config/nvim/init.lua".source = ./dotfiles/nvim/init.lua;
    ".config/nvim/plugins.lua".source = ./dotfiles/nvim/plugins.lua;

    ".config/git/config".source = ./dotfiles/gitconfig;
    ".config/fontconfig/fonts.conf".source = ./dotfiles/fontconfig/fonts.conf;

    ".config/btop/btop.conf".source = ./dotfiles/btop/btop.conf;
  };
 

# THEMES
  home.file = {
    ".local/share/themes".source = ./dotfiles/themes;

    ".config/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name = "Juno-ocean"
      gtk-application-prefer-dark-theme = true
      gtk-icon-theme-name = "Qogir"
      '';
  };
}
