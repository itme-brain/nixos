{ pkgs, lib, config, ... }:

{
  home.packages = with pkgs; [
    nix-init
    nix-prefetch-git
    nurl

    pkg-config
    qrencode

    docker
  ];

  programs = {
    bash = {
      initExtra = import ./config/penpot.nix;
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };

  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };
}
