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

    # vc4 needs a larger Contiguous Memory Allocator pool than the 64 MiB
    # default. Without this, the GPU can't allocate framebuffers and spams
    # "swiotlb buffer is full" — no video output.
    kernelParams = [ "cma=256M" ];
  };

  # Pi 4 GPU acceleration. Per the NixOS wiki, two options are needed:
  #   fkms-3d                -> enables the fake-KMS + V3D renderer overlay
  #   apply-overlays-dtmerge -> activates the dtmerge-based overlay pipeline
  # Without apply-overlays-dtmerge, hardware.deviceTree.overlays entries are
  # silently ignored — they show up in the evaluated config but never get
  # merged into the emitted DTB.
  # https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi_4
  hardware.raspberry-pi."4" = {
    fkms-3d.enable = true;
    apply-overlays-dtmerge.enable = true;
  };

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