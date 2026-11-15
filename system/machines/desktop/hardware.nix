{ config, lib, pkgs, modulesPath, ... }:

with lib;
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  options.monitors = mkOption {
    type = types.listOf (types.submodule {
      options = {
        name = mkOption { type = types.str; example = "HDMI-A-1"; };
        description = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Physical monitor make, model and serial; preferred over the connector name.";
        };
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
      { name = "HDMI-A-1"; description = "Samsung Electric Company C24F390 HCPRC03514"; width = 1920; height = 1080; x = 0;    y = 0; scale = 1.0; refreshRate = 60; }
      { name = "DP-1"; description = "Samsung Electric Company Odyssey G40B HCJW703270"; width = 1920; height = 1080; x = 1920; y = 0; scale = 1.0; refreshRate = 60; }
    ];

    boot = {
      initrd = {
        availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
        kernelModules = [ "dm-snapshot" ];
      };
      extraModulePackages = [ ];
      #kernelPackages = pkgs.linuxPackages_zen;
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

      # NVIDIA packages: restore when switching back to the NVIDIA GPU.
      # cudaPackages.cudatoolkit
      # cudaPackages.cudnn
      # nvidia-vaapi-driver
    ];

    hardware = {
      cpu = {
        intel = {
          updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        };
      };
      amdgpu.initrd.enable = true;
      # NVIDIA configuration: restore when switching back to the NVIDIA GPU.
      # nvidia = {
      #   open = true;
      #   modesetting.enable = true;
      #   nvidiaSettings = true;
      #   package = config.boot.kernelPackages.nvidiaPackages.stable;
      # };
      # nvidia-container-toolkit.enable = true;
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    services.xserver.videoDrivers = [ "amdgpu" ];
    # NVIDIA: restore this in place of the AMD driver when switching back.
    # services.xserver.videoDrivers = [ "nvidia" ];

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
