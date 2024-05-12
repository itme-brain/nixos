{ disks ? [ "/dev/nvme0n1" "/dev/sdb" ], ... }:

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
              start = "200M";
              end = "100%FREE";
              content = {
                type = "lvm_pv";
                vg = "stick";
              };
            }
          ];
        };
      };
    };
    disk = {
      two = {
        type = "disk";
        device = builtins.elemAt disks 1;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              start = "0";
              end = "100%FREE";
              content = {
                type = "lvm_pv";
                vg = "ssd";
              };
            }
          ];
        };
      };
    };

    lvm_vg = {
      stick = {
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
              name = "NixOS";
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
    lvm_vg = {
      ssd = {
        type = "lvm_vg";
        lvs = {
          aaa = {
            size = "1M";
          };
          zzz = {
            size = "1M";
          };
          home = {
            size = "200G";
            content = {
              name = "home";
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
            };
          };
        };
      };
    };
  };
}
