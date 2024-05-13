{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/79093c66-1283-44d4-b03c-f87956bbada1";
      fsType = "ext4";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/1e2d04b2-9a02-4de6-88cc-1e35d0838036";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/0509-1D1F";
      fsType = "vfat";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
