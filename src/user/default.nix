{ pkgs, lib, config, ... }:

{ imports = [
  ./configs
  ./modules { inherit config; }
  ];
}
