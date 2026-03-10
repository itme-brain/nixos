{ disk ? "/dev/vda" }:
{
  disko.devices = {
    disk = {
      one = {
        type = "disk";
        device = disk;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "200M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            primary = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "vm";
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      vm = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "defaults" ];
            };
          };
        };
      };
    };
  };
}
