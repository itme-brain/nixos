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
      device = "/dev/disk/by-uuid/495f5e7b-d9e4-4663-88c5-7021e7292535";
      fsType = "ext4";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/cd0e5c29-716d-47f2-92f4-46ee9fca5af3";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/C061-EE77";
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
        settingsSha256 = "sha256-sX9dHEp9zH9t3RWp727lLCeJLo8QRAGhVb8iN6eX49g=";
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
