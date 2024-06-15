{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.browser.chromium;

in
{ options.modules.user.gui.browser.chromium = { enable = mkEnableOption "Enable Chromium browser"; };
  config = mkIf cfg.enable {
    programs = {
      chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium;
        extensions = [
          {
            id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
            crxPath = /home/${config.user.name}/.config/chromium/Extensions/ublock.crx;
            version = "1.58.0";
          }
          {
            id = "dbepggeogbaibhgnhhndojpepiihcmeb";
            crxPath = /home/${config.user.name}/.config/chromium/Extensions/vimium.crx;
            version = "2.1.2";
          }
          {
            id = "naepdomgkenhinolocfifgehidddafch";
            crxPath = /home/${config.user.name}/.config/chromium/Extensions/browserpass.crx;
            version = "3.8.0";
          }
        ];
      };
      browserpass = {
        enable = true;
      };
    };

    home = {
      file.".config/chromium/Extensions" = {
        source = ./config/extensions;
        recursive = true;
      };
    };
  };
}
