{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.neovim;

in
{ options.modules.user.gui.neovim = { enable = mkEnableOption "user.gui.neovim"; };
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraPackages = import ./config/servers.nix { inherit pkgs; };
    };

    home.file.".config/nvim" = {
      source = ./config/lazyvim;
      recursive = true;
    };
    home.packages = with pkgs; [
      lazygit
      #gcc
    ];
  };
}
