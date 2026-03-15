{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.sops;

in
{
  options.modules.system.sops = { enable = mkEnableOption "Enable sops-nix"; };

  config = mkIf cfg.enable {
    # Smartcard daemon for Yubikey (GPG, etc.)
    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];

    environment.systemPackages = with pkgs; [
      age
      sops
    ];

    # Per-machine age key for system secrets (boot-time, unattended)
    # This is the sops-nix default path
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";

    # Symlink for root so `sudo sops` finds the key automatically
    systemd.tmpfiles.rules = [
      "d /root/.config/sops/age 0700 root root -"
      "L+ /root/.config/sops/age/keys.txt - - - - /var/lib/sops-nix/key.txt"
    ];
  };
}
