{ config, lib, ... }:

{
  imports = [ ./modules/home-manager/user/configs ];

  wsl = {
    enable = true;
    defaultUser = lib.mkDefault config.user.name;
    nativeSystemd = true;

    wslConf = {
      boot.command = "cd";
      network = {
        hostname = "wsl";
        generateHosts = true;
      };
    };
  };
}
