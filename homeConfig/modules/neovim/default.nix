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
      plugins = import ./config/plugins.nix { inherit pkgs; };
      extraPackages = import ./config/lsp.nix { inherit pkgs; };
    };
  };
}
