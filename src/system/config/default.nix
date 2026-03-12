{ lib, pkgs, config, ... }:

with lib;
{
  options = {
    machines = mkOption {
      description = "Machine Configurations";
      type = types.attrs;
      default = {
        keys = import ./keys { inherit lib; };
      };
    };
  };
}
