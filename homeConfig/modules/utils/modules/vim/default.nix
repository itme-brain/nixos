{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.vim;

in
{ options.modules.vim = { enable = mkEnableOption "vim"; };
  config = mkIf cfg.enable {
    programs.vim = {
      enable = true;
      package = pkgs.vim;
      extraConfig = import ./config/vimrc;
    };
    programs.bash.shellAliases = {
      vi = "${pkgs.vim}/bin/vim";
    };
  };
}
