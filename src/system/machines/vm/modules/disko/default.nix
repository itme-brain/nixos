{ disks ? [ "/dev/vda" ], ... }:

{
  disko.devices = {
    disk = {
      one = {
        device = builtins.elemAt disks 0;
        type = "disk";
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
              bootable = true;
              priority = 1;
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
          aaa = {
            size = "1M";
          };
          zzz = {
            size = "1M";
          };
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
