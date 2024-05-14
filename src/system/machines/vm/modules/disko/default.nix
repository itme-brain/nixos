{ disks ? [ "/dev/vda" ], ... }:

{
  disko.devices = {
    disk = {
      one = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "boot";
              start = "0";
              end = "200M";
              fs-type = "fat32";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "root";
              start = "200M";
              end = "100%FREE";
              content = {
                type = "lvm_pv";
                vg = "vm";
              };
            }
          ];
        };
      };
    };

    lvm_vg = {
      vm = {
        type = "lvm_vg";
        lvs = {
          aaa = {
            size = "1M";
          };
          zzz = {
            size = "1M";
          };
          root = {
            size = "100%";
            content = {
              name = "nixos";
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    };
  };
}
