{ config, lib, pkgs, modulesPath, ... }:

with lib;
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  options.monitors = mkOption {
    type = types.listOf (types.submodule {
      options = {
        name = mkOption { type = types.str; example = "HDMI-A-1"; };
        width = mkOption { type = types.int; };
        height = mkOption { type = types.int; };
        x = mkOption { type = types.int; };
        y = mkOption { type = types.int; };
        scale = mkOption { type = types.float; };
        refreshRate = mkOption { type = types.int; };
      };
    });
    default = [];
    description = "System monitor configuration";
  };

  config = {
    monitors = [
      { name = "HDMI-A-1"; width = 1920; height = 1080; x = 0;    y = 0; scale = 1.0; refreshRate = 60; }
      { name = "DP-1";     width = 1920; height = 1080; x = 1920; y = 0; scale = 1.0; refreshRate = 60; }
    ];

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

      mesa
      mesa-demos

      cudaPackages.cudatoolkit
      cudaPackages.cudnn
    ];

    hardware = {
      cpu = {
        intel = {
          updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        };
      };
      nvidia = {
        open = true;
        modesetting.enable = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    # Despite confusing name, this configures userspace nvidia libraries
    services.xserver.videoDrivers = [ "nvidia" ];

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        runAsRoot = true;
      };
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  };
}
