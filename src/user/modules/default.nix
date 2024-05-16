{ lib, ... }:

with lib;
let
  mkModules = dir: recursiveUpdate
    (attrsets.mapAttrs (_: moduleDir: {
      inherit (moduleDir) default;
    }) (filterAttrs (n: v: isAttrs v) (attrsets.mapAttrs (_: v: builtins.readDir v) dir)))
    { inherit (dir) default; };

in
{
  imports = mkModules ./.;
}
