{ config, ... }:

{ imports = [
    ./configs
    ./modules { inherit config; }
  ];
}
