{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.neovim;

in
{ options.modules.user.neovim = { enable = mkEnableOption "user.neovim"; };
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraWrapperArgs = [
        "--suffix"
        "PATH"
        ":"
        "${config.home.homeDirectory}/.npm-global/bin"
      ];
      extraPackages = with pkgs; [
        gcc
        cargo
        rustc

        fzf
        fd
        ripgrep
        bat
      ];
    };

    home.file.".config/nvim" = {
      # Keep Neovim's config writable. In a flake, `./nvim` is copied into
      # /nix/store before Home Manager can create an out-of-store symlink.
      source = ./nvim;
      recursive = true;
    };
  };
}
