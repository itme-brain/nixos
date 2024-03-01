{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

# Kernel
  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "intel_iommu=on" ];
  boot.kernelModules = [ "kvm-intel" "virtio" "vfio-pci" "coretemp" ];

# FStab
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/af24c5b3-8a6e-4333-a61d-922a97928cae";
      fsType = "ext4";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/1639ee20-28d6-4649-814d-ba981c138b35";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/74B9-4AAF";
      fsType = "vfat";
    };
  };

# GPU
  hardware.nvidia.open = true;

# Virtualisation
  nix.settings.system-features = [ "kvm" ];

  environment.systemPackages = with pkgs; [
    virt-manager
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      ovmf.enable = true;
    };
  };

# CPU
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
