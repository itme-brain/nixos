{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };
    extraModulePackages = [ ];
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [ "intel_iommu=on" ];
    kernelModules = [ "kvm-intel" "virtio" "vfio-pci" "coretemp" ];
  };

  environment.systemPackages = with pkgs; [
    linuxHeaders

    vulkan-headers
    vulkan-loader
    vulkan-tools
    vulkan-extension-layer
    glxinfo
    mesa

    cudaPackages.cudatoolkit
    cudaPackages.cudnn
  ];

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

  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    cpu = {
      intel = {
        updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "550.90.07";
        sha256_64bit = "sha256-Uaz1edWpiE9XOh0/Ui5/r6XnhB4iqc7AtLvq4xsLlzM=";
        openSha256 = "sha256-mRUTEWVsbjq+psVe+kAT6MjyZuLkG2yRDxCMvDJRL1I=";
        settingsSha256 = "sha256-c30AQa4g4a1EHmaEu1yc05oqY01y+IusbBuq+P6rMCs=";
        persistencedSha256 = "sha256-11tLSY8uUIl4X/roNnxf5yS2PQvHvoNjnd2CB67e870=";
      };
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = true;
      ovmf.enable = true;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
