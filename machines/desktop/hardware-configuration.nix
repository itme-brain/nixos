{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "coretemp" ];
  boot.extraModulePackages = [ ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/af24c5b3-8a6e-4333-a61d-922a97928cae";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/1639ee20-28d6-4649-814d-ba981c138b35";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/74B9-4AAF";
      fsType = "vfat";
    };

  services.xserver.videoDrivers = [ "nvidia" ];                         # Uncomment    
  hardware = {                                                        # this 
    opengl.enable = true;                                             # codeblock
    nvidia = {                                                        # for
    package = config.boot.kernelPackages.nvidiaPackages.stable;       # NVIDIA
    modesetting.enable = true;                                        # proprietary
    };                                                                # driver
  };                                                                  # support

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

