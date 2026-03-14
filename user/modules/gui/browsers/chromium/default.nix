{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.browser.chromium;

in
{ options.modules.user.gui.browser.chromium = { enable = mkEnableOption "Enable Chromium browser"; };
  config = mkIf cfg.enable {
    programs = {
      chromium = rec {
        enable = true;
        package = pkgs.ungoogled-chromium;
        extensions =
        let
          vrs = package.version;
        in
        [
          rec {
            id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
            crxPath = builtins.fetchurl {
              url = "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=${vrs}&acceptformat=crx2,crx3&x=id%3D${id}%26uc";
              name = "ublock_${version}.crx";
              sha256 = "0ycnkna72n969crgxfy2lc1qbndjqrj46b9gr5l9b7pgfxi5q0ll";
            };
            version = "1.62.0";
          }
          rec {
            id = "dbepggeogbaibhgnhhndojpepiihcmeb";
            crxPath = builtins.fetchurl {
              url = "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=${vrs}&acceptformat=crx2,crx3&x=id%3D${id}%26uc";
              name = "vimium_${version}.crx";
              sha256 = "0m8xski05w2r8igj675sxrlkzxlrl59j3a7m0r6c8pwcvka0r88d";
            };
            version = "2.1.2";
          }
          rec {
            id = "naepdomgkenhinolocfifgehidddafch";
            crxPath = builtins.fetchurl {
              url = "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=${vrs}&acceptformat=crx2,crx3&x=id%3D${id}%26uc";
              name = "browserpass_${version}.crx";
              sha256 = "074sc9hxh7vh5j79yjhsrnhb5k4dv3bh5vip0jr30hkkni7nygbd";
            };
            version = "3.9.0";
          }
        ];
      };
      browserpass = {
        enable = true;
      };
    };
  };
}
