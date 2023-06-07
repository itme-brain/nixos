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
      
#      extraLuaConfig = import ./config/init.nix;
      plugins = with pkgs.vimPlugins; [
        LazyVim
      ];
      extraPackages = import ./config/servers.nix { inherit pkgs; };
    };
  };
}
