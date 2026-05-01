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
      extraPackages = with pkgs; [
        lazygit
        gcc
        fzf
        rg
      ];
    };

    home.file.".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
  };
}
