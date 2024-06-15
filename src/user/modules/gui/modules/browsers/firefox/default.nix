{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.browser.firefox;

in
{ options.modules.user.gui.browser.firefox = { enable = mkEnableOption "Enable Firefox browser"; };
  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      nativeMessagingHosts = with pkgs; [
        passff-host
      ];
      profiles = {
        "${config.user.name}" = {
          bookmarks = config.user.bookmarks;
        };
      };
    };
  };
}
