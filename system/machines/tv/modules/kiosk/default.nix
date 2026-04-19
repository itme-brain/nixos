{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.kiosk;
in
{
  options.modules.system.kiosk = {
    enable = mkEnableOption "kiosk mode (Cage + Firefox fullscreen browser)";

    user = mkOption {
      type = types.str;
      description = "user account the kiosk session runs as";
    };

    url = mkOption {
      type = types.str;
      default = "about:blank";
      description = "URL loaded by Firefox on startup";
    };
  };

  config = mkIf cfg.enable {
    # Cage is a minimal Wayland compositor that runs exactly one program
    # fullscreen. Combined with auto-login it gives us a zero-chrome kiosk.
    services.cage = {
      enable = true;
      user = cfg.user;
      program = ''
        ${pkgs.firefox}/bin/firefox \
          --kiosk \
          ${cfg.url}
      '';
    };

    # System-wide Firefox policies. Writes /etc/firefox/policies/policies.json
    # which Firefox reads regardless of how it's launched.
    programs.firefox = {
      enable = true;
      policies = {
        # Force-install uBlock Origin from AMO. The "latest.xpi" URL is
        # Mozilla's stable redirect — it always resolves to the current
        # release and is explicitly supported for enterprise policy use.
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
        };

        # Trim everything Firefox does that makes no sense on a TV
        DisableTelemetry = true;
        DisablePocket = true;
        DisableFirefoxStudies = true;
        DisableProfileImport = true;
        DontCheckDefaultBrowser = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        NoDefaultBookmarks = true;
        PasswordManagerEnabled = false;

        # DRM on — required for Netflix/Prime/etc. to even attempt playback.
        # On aarch64 the Widevine CDM still has to be fetched at runtime and
        # may be refused by streaming services; YouTube/Twitch/non-DRM work
        # regardless.
        EncryptedMediaExtensions = {
          Enabled = true;
          Locked = true;
        };
      };
    };

    # Firefox runs on Wayland cleanly only with this env var.
    environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";

    # PipeWire for audio out over HDMI / 3.5mm
    services.pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
  };
}
