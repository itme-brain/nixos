{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.utils.writing;

in
{ options.modules.user.utils.writing = { enable = mkEnableOption "Enable writing tools"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mdbook
      pandoc
      asciidoctor
    ];
  };
}
