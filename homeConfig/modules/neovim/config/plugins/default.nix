{ pkgs, lib, ... }:

let
  lazyvim = import ./lazyvim;

in
builtins.concatMap (dir: dir { inherit pkgs lib; }) [
  lazyvim
]
