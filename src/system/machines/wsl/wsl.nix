{ pkgs, config, ... }:

{
  imports = [
    ../../../user
  ];

  wsl = {
    enable = true;
    defaultUser = pkgs.lib.mkDefault "${config.user.name}";
    nativeSystemd = true;

    wslConf = {
      boot.command = "cd";
      network = {
        hostname = "plato";
        generateHosts = true;
      };
    };
  };
}
