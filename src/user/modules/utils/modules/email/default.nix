{ lib, config, ... }:

{
  programs.aerc = {
    enable = true;
  };

  home.file.".config/aerc" = {
    source = ./config;
    recursive = true;
  };
}
