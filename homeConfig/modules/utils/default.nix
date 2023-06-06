{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.utils;

in 
{ options.modules.utils = { enable = mkEnableOption "utils"; };
  config = mkIf cfg.enable {
    
    services.syncthing.enable = true;

    home.packages = with pkgs; [
      wget curl tree neofetch
      unzip fping calc qrendcode
      fd pkg-config pciutils 
      neofetch mdbook rsync
      android-studio docker
      gcc gnumake
    ];  
  };
}
