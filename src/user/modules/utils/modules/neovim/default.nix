{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.utils.neovim;

in
{ options.modules.user.utils.neovim = { enable = mkEnableOption "user.utils.neovim"; };
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
