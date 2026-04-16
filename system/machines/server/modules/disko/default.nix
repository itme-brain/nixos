{ lib, ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            lvm = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "vg0";
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      vg0 = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "200G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
          data = {
            size = "1T";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/data";
            };
          };
          bitcoin = {
            size = "1T";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/var/lib/bitcoin";
            };
          };
          frigate = {
            size = "3T";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/var/lib/frigate";
            };
          };
          # ~300GB left unallocated for future growth
        };
      };
    };
  };
}
