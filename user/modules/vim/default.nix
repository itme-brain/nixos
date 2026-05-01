{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.vim;

in
{ options.modules.user.vim = { enable = mkEnableOption "user.vim"; };
  config = mkIf cfg.enable {
    programs.bash.shellAliases = {
      vi = "${pkgs.vim}/bin/vim";
    };

    home = {
      packages = with pkgs; [
        vim
       ];
      file.".vim" = {
        source = config.lib.file.mkOutOfStoreSymlink ./vim;
        recursive = true;
      };
    };
  };
}
