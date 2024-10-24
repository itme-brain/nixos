{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.dev.vim;

in
{ options.modules.user.dev.vim = { enable = mkEnableOption "Enable VIM module"; };
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
