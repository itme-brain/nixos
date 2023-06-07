{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.neovim;

in 
{ options.modules.neovim = { enable = mkEnableOption "neovim"; };
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

# TODO: Fix declarative setup
#      extraLuaConfig = import ./config/init.nix;
#      plugins = with pkgs.vimPlugins; [
#        LazyVim
#     ];
      extraPackages = import ./config/servers.nix { inherit pkgs; };
    };

# Bandaid fix until I can get the declarative setup working
    home.file.".config/nvim" = {
      source = ./config/lazyvim;
      recursive = true;
    };
  };
}
