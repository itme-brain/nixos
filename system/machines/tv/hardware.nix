{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "usbhid" ];
      kernelModules = [ ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];

    # Pi boots via extlinux from the Hydra SD image — not GRUB/systemd-boot
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  # The nixos-hardware Pi 4 profile ships a base DTB with gpu/v3d/hdmi nodes
  # all status="disabled". The `vc4-kms-v3d.dtbo` overlay flips them on — but
  # U-Boot (NixOS's bootloader path on aarch64 Pi) bypasses the Pi firmware's
  # config.txt dtoverlay mechanism. Apply the overlay at NixOS build time so
  # it's baked into the DTB U-Boot hands to the kernel.
  hardware.deviceTree.overlays = [
    {
      name = "vc4-kms-v3d";
      dtboFile = "${config.boot.kernelPackages.kernel}/dtbs/overlays/vc4-kms-v3d.dtbo";
    }
  ];

  # UUIDs are baked into the Hydra SD image — identical on every Pi flashed
  # from that image. FIRMWARE (FAT) holds the Pi bootloader; NIXOS_SD (ext4)
  # is root. /boot/firmware must be mounted so nixos-rebuild can update
  # extlinux config on subsequent rebuilds.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-uuid/2178-694E";
    fsType = "vfat";
    options = [ "nofail" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}