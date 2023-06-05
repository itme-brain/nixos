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
    google-chrome
    (tor-browser-bundle-bin.override {
      useHardenedMalloc = false; # Nix specific bug in tor browser requires disabling useHardenedMalloc
    })

    spotify
    discord

    alacritty
    ranger
    highlight
    imv
    gimp

    android-studio
    gh

    syncthing
    rsync
    wget
    curl
    btop
    pciutils
    tree
    git
    git-review
    openssh
    unzip
    lsd
    fping
    calc
    qrencode
    mdbook
    
    bash-completion
    pkg-config
    docker
    nix-init
    lazygit
    ripgrep
    fd
    luajit

    trezor-suite
    trezorctl
    electrum

    keepassxc
    neofetch
    evince
    wireguard-tools
    
    nodejs
    gcc

    ghc
    cabal-install
    haskellPackages.hoogle
    cabal2nix
    
    python3

# LSPs
    nodePackages.eslint
    nodePackages.vscode-langservers-extracted
    nodePackages.typescript-language-server
    nodePackages.diagnostic-languageserver
    nodePackages.pyright
    nodePackages.purescript-language-server
    nodePackages."@tailwindcss/language-server"
    nodePackages.bash-language-server
    haskell-language-server
    nil
    marksman
    sumneko-lua-language-server
  ];

# PROGRAM CONFIGS

# DIRENV
  programs.direnv = { 
    enable = true;
    nix-direnv.enable = true;
  };

# NEOVIM
  programs.neovim = {
    enable = true;
#    plugins = with pkgs; [
#      vimPlugins.nvim-treesitter.withAllGrammars
#    ];
  };

# SERVICES

# GPG SSH AGENT 
  home.sessionVariables = {
    SSH_AUTH_SOCK = "${config.xdg.dataHome}/gnupg/S.gpg-agent.ssh";
  };
 

# DOTFILE SYMLINKS
  home.file = {
    ".gitconfig".source = ./dotfiles/gitconfig;

    ".config/" = {
        source = ./dotfiles;
        recursive = true;
      };
    
    ".bashrc".source = ./dotfiles/bash/bashrc;
    ".bash_profile".source = ./dotfiles/bash/bash_profile;

    ".local/share/themes" = {
        source = ./dotfiles/themes;
        recursive = true;
      };
  };
}
