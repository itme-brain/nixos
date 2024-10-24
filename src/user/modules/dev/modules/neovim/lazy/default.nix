{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.dev.neovim.lazy;

in
{ options.modules.user.dev.neovim.lazy = { enable = mkEnableOption "Enable Neovim module"; };
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraPackages = import ./config/pkgs.nix { inherit pkgs; };
    };

    home.file.".config/nvim" = {
      source = ./config/nvim;
      recursive = true;
    };
  };
}
