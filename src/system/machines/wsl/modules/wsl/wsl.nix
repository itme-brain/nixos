{ config, lib, ... }:

{
  imports = [ ../../../../../user/config ];

  wsl = rec {
    enable = true;
    defaultUser = lib.mkDefault config.user.name;
    nativeSystemd = true;

    wslConf = {
      user.default = lib.mkDefault defaultUser;
      boot.command = "cd";
      network = {
        hostname = "${config.networking.hostName}";
        generateHosts = true;
      };
    };
  };
}
