{ pkgs, lib, config, user, ... }:

with lib;
let 
  cfg = config.modules.firefox;

in 
{ options.modules.firefox = { enable = mkEnableOption "firefox"; };
  config = mkIf cfg.enable {
    programs.firefox = {
      enabled = true;
      profiles.${user} = {
        isDefault = true;
        search.default = "Startpage";
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          darkreader
          keepassxc-browser
          multi-account-containers
        ];

        settings = {
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";

          "dom.security.https_only_mode" = true;
          "media.peerconnection.enabled" = false;
          "browser.formfill.enable" = false;

          "privacy.sanitize.sanitizeOnShutdown" = true;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "browser.ping-centre.telemetry" = false;

          "privacy.resistFingerprinting" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.cryptomining.enabled" = true;

          "geo.enabled" = false;
          "privacy.trackingprotection.enabled" = true;
        };
      };
    };

    home.packages = [
      google-chrome
      (tor-browser-bundle-bin.override {
        useHardenedMalloc = false; # NixOS bug requires this
      })
    ];
  };
}
