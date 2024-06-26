{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.utils.vim;

in
{ options.modules.user.utils.vim = { enable = mkEnableOption "user.utils.vim"; };
  config = mkIf cfg.enable {
    programs.bash.shellAliases = {
      vi = "${pkgs.vim}/bin/vim";
    };

    home = {
      packages = with pkgs; [
        vim
       ];
      file.".vim" = {
        source = ./config;
        recursive = true;
      };
    };
  };
}
