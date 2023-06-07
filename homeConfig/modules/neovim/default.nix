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
      
      extraConfig = import ./config/init.nix;
      plugins = import (./config/plugins) { inherit pkgs lib; };
      extraPackages = import ./config/servers.nix { inherit pkgs; };
    };
  };
}
