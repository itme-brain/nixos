{ lib, config, ... }:

with lib;
let
  gui = config.modules.user.gui.wm;

  wm = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues gui);
  };

in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    initExtra = import ./config/prompt.nix;
    bashrcExtra = import ./config/bashrc.nix;
    shellAliases = import ./config/alias.nix;
  };

  programs = {
    ripgrep.enable = true;
    eza = {
      enable = true;
      enableAliases = true;
    } // optionalAttrs wm.enable {
      icons = true;
    };
  };
}
