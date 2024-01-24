{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.vim;

in
{ options.modules.vim = { enable = mkEnableOption "vim"; };
  config = mkIf cfg.enable {
    programs.vim = {
      enable = true;
      extraConfig = import ./config/vim.nix;
    };
    programs.bash.shellAliases = {
      vi = "vim";
    };
  };
}
