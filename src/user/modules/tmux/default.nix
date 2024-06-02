{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.tmux;
  gui = config.modules.user.gui.wm;

  wm = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues gui);
  };

in
{ options.modules.user.tmux = { enable = mkEnableOption "Enable tmux module"; };
  config = mkIf cfg.enable {
    programs.bash = mkIf (!wm.enable) {
      profileExtra = import ./config/shellHook.nix;
    };

    programs.tmux = {
      enable = true;
      newSession = true;
      disableConfirmationPrompt = true;
      keyMode = "vi";
      mouse = if wm.enable then true else false;

      prefix = "M";
      #shell = "\${pkgs.bash}/bin/bash";

      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = tilish;
          extraConfig = ''
            set -g @tilish-default 'tiled'
          '';
        }
      ];

      extraConfig = import ./config/tmux.nix;
    };
  };
}
