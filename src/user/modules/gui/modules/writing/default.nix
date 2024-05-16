{ pkgs, lib, config, ... }:

{
  home.packages = with pkgs; [
    mdbook
    texlive.combined.scheme-tetex
    pandoc
    asciidoctor
  ];
}
