{ config, lib, ... }:

{
  imports = [ ../../../../../user ];

  wsl = rec {
    enable = true;
    defaultUser = lib.mkDefault config.user.name;
    useWindowsDriver = true;

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
