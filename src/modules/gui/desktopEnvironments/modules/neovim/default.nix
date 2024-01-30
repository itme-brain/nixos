{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.gui.neovim;

in
{ options.modules.gui.neovim = { enable = mkEnableOption "gui.neovim"; };
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      extraPackages = import ./config/servers.nix { inherit pkgs; };
    };

    home.file.".config/nvim" = {
      source = ./config/lazyvim;
      recursive = true;
    };
    home.packages = with pkgs; [
      lazygit
    ];
  };
}
