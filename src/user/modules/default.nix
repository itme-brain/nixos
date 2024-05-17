{ lib, config, ... }:

with builtins;
let

  mkModules = dir: pathAcc: (
    foldl' (attrs: node:
    let
    path = "${dir}/${node}";
    accumulatedPath =
      if dir == ./.
        then node
      else if node != "modules"
        then "${pathAcc}.${node}"
      else
        pathAcc;
    in
    if readFileType node == "directory"
      then mkModules path accumulatedPath // attrs
    else if node == "default.nix" then
      let
      enableOpt = {
        ${accumulatedPath} = {
          enable = lib.mkEnableOption "Enable ${accumulatedPath} module";
        };
      };
      moduleCfgs = lib.mkIf config.modules.user.${accumulatedPath}.enable
        (import path);
      in
      {
        opts = attrs.opts // enableOpt;
        cfgs = attrs.cfgs // moduleCfgs;
      }
    else
      attrs
    ) { opts = {}; cfgs = {}; } (filter (node: readFileType "${dir}/${node}" == "directory" || node == "default.nix" && node != "config") (attrNames (readDir dir)))
  );

  result = mkModules ./.;

in
{
  options.modules.user = result.opts;
  config = result.cfgs;
}
