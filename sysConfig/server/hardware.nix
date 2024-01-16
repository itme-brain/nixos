{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = { 
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        enableCryptodisk = true;
        device = "nodev";
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = false;
    };
    initrd = {
      availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
      kernelModules = [ "dm-snapshot" ];
      luks = {
        devices = {
          nixos = {
            device = "/dev/disk/by-uuid/b0a91fc9-a019-4ea9-8d97-8dfddef7cc17";
          };
        };
      };
    };
  };

  fileSystems."/" = {
      device = "/dev/disk/by-uuid/79093c66-1283-44d4-b03c-f87956bbada1";
      fsType = "ext4";
    };

  fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/0509-1D1F";
      fsType = "vfat";
    };

  fileSystems."/home" = {
      device = "/dev/disk/by-uuid/1e2d04b2-9a02-4de6-88cc-1e35d0838036";
      fsType = "ext4";
    };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
