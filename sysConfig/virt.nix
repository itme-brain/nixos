{ config, pkgs, lib, ... }:

{
  boot = {
    kernelParams = [ "intel_iommu=on" ];
    kernelModules = [ "kvm-intel" "virtio" "vfio-pci" ];

# TODO: (bryan) - Fix GPU passthrough
#    extraModprobeConfig = ''
#     options vfio-pci ids=10de:1f82,10de:10fa
#    '';
  };

  virtualisation.libvirtd.enable = true;
 
  environment.systemPackages = with pkgs; [
    qemu_kvm
    libvirt
    virt-manager
    OVMF 
  ];
}


