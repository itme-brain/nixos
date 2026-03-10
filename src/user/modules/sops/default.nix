{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.sops;
  keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  ageIdentity = config.user.keys.age.yubikey or null;

in
{
  options.modules.user.sops = {
    enable = mkEnableOption "Enable sops-nix user secrets";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      age
      age-plugin-yubikey
      sops
    ];

    # Write identity file from user.keys.age.yubikey
    home.file.".config/sops/age/keys.txt" = mkIf (ageIdentity != null) {
      text = ageIdentity;
    };

    # Configure sops for home-manager
    sops = {
      age.keyFile = keyFile;

      # Secrets will be decrypted to $XDG_RUNTIME_DIR/secrets.d
      # and symlinked to ~/.config/sops-nix/secrets/
    };
  };
}
