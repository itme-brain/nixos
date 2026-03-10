{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.sops;

in
{
  options.modules.system.sops = {
    enable = mkEnableOption "Enable sops-nix with Yubikey support";
  };

  config = mkIf cfg.enable {
    # Smartcard daemon for Yubikey communication
    services.pcscd.enable = true;

    # Yubikey udev rules
    services.udev.packages = [ pkgs.yubikey-personalization ];

    # System packages for age + yubikey
    environment.systemPackages = with pkgs; [
      age
      age-plugin-yubikey
      sops
    ];

    # Point sops to the age identity file (will be created by age-plugin-yubikey)
    sops.age.keyFile = "/home/${config.user.name}/.config/sops/age/keys.txt";
  };
}
