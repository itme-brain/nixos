{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };
    extraModulePackages = [ ];
    kernelParams = [ "intel_iommu=off" ];
    kernelModules = [ "kvm-intel" "virtio" "vfio-pci" "coretemp" "amdgpu" ];
  };

  environment.systemPackages = with pkgs; [
    linuxHeaders

    vulkan-headers
    vulkan-loader
    vulkan-tools
    vulkan-extension-layer

    mesa
    mesa-demos

    libGL

    glxinfo
    clinfo
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/6e964c61-ea77-48cc-b495-6a8516b8e756";
      fsType = "xfs";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/db504fb8-14f8-4292-b745-32d6255c4893";
      fsType = "xfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/61E7-6E56";
      fsType = "vfat";
    };

    "/var/lib/libvirt/images" = {
      device = "/home/VMs";
      options = [ "bind" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /home/VMs 0755 root root" 
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = true;
      ovmf.enable = true;
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
  };

  services.xserver.videoDrivers = [ "amdgpu" ];
  
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
