{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.utils.vim;

in
{ options.modules.utils.vim = { enable = mkEnableOption "utils.vim"; };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ 
        vim
       ];
      file.".vim" = {
        source = ./config;
        recursive = true;
      };
    };
    programs.bash.shellAliases = {
      vi = "${pkgs.vim}/bin/vim";
    };
  };
}
