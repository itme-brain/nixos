let
  dev = "/dev/disk/by-id/ata-CT2000MX500SSD1_2137E5D2D47D";

in
{
  disko.devices = {
    disk = {
      one = {
        type = "disk";
        device = dev;
        content = {
          type = "table";
          format = "gpt";
          partitions = {
            boot = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            primary = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "nix";
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      nix = {
        type = "lvm_vg";
        lvs = {
          aaa = {
            size = "1M";
          };
          zzz = {
            size = "1M";
          };
          root = {
            size = "252G";
            content = {
              name = "root";
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
          home = {
            size = "100%FREE";
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
