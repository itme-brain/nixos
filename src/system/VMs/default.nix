{ pkgs, lib, config, ... }:

{
  virtualisation.libvirt = {
    enable = true;
    verbose = true;

    connections."qemu:///system" = {
      domains = [
        {
          definition = ./config/machines/Test_Bench1.xml;
        }
      ];

      pools = [
        {
          definition = ./config/storage/pools/default.xml;
          active = true;
          volumes = [
            {
              definition = ./config/storage/volumes/rocky9.xml;
            }
          ];
        }
      ];

      networks = [
        {
          definition = ./config/networks/virbr0.xml;
          active = true;
        }
      ];
    };
  };
}
