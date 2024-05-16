{ pkgs, lib, config, ... }:

{
  programs.bash.shellAliases = {
    vi = "${pkgs.vim}/bin/vim";
  };

  home = {
    packages = with pkgs; [
      vim
      ];
    file.".vim" = {
      source = ./config;
      recursive = true;
    };
  };
}
