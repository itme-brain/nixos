{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.neovim;

in
{ options.modules.neovim = { enable = mkEnableOption "neovim"; };
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
