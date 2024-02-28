{ disks ? [ "/dev/nvme0n1" "/dev/sda" ], ... }: 

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
              end = "100M";
              fs-type = "fat32";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              start = "100M";
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
              end = "100%";
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
            size = "100%";
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
