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
      device = "/dev/disk/by-uuid/d4e0a913-9ba8-451e-9086-b6d5d483dd9f";
      fsType = "ext4";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/e1780967-0b87-46ff-8200-430d79d59e47";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/74B9-4AAF";
      fsType = "vfat";
    };
  };

# GPU
  services.xserver.videoDrivers = lib.mkDefault ["nvidia"];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.nvidia = {
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

# Virtualisation
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
