{ pkgs, lib, config, ... }:

{
  virtualisation.libvirt = {
    enable = true;
    verbose = true;

    connections."qemu:///system" = {
      domains = [
        {
          definition = ./machines/Test_Bench1.xml;
        }
      ];

      pools = [
        {
          definition = ./storage/pools/default.xml;
          active = true;
          volumes = [
            {
              definition = ./storage/volumes/rocky9.xml;
            }
          ];
        }
      ];

      networks = [
        {
          definition = ./networks/virbr0.xml;
          active = true;
        }
      ];
    };
  };
}
