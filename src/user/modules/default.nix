{ lib ? import <nixpkgs>, config ? import <nixpkgs>, ... }:

with builtins;
let
  moduleType = "user";

  mkModules = dir: pathAcc: (
    trace "Processing dir: ${dir} with pathAcc: ${pathAcc}" (
    foldl' (attrs: node:
      let
      path = "${dir}/${node}";
      accPath =
        if pathAcc == ""
          then node
        else if node != "modules"
          then "${pathAcc}.${node}"
        else
          pathAcc;
      in
      if readFileType path == "directory" then
        trace "Scanning directory: ${path}" (mkModules path pathAcc // attrs)
      else if node == "default.nix" && dir != ./. then
        let
        moduleOpts = {
          ${accPath} = {
            enable = lib.mkEnableOption "Enable ${node} module";
          };
        };
        moduleCfgs = {
          ${accPath} = lib.mkIf config.modules.${moduleType}.${accPath}.enable (import path);
        };
        in
        trace "Processing node: ${node} at path: ${path} with accumulatedPath: ${accPath}" (
        {
          opts = attrs.opts // moduleOpts;
          cfgs = attrs.cfg // moduleCfgs;
        }
        )
      else
        attrs
    )) { opts = {}; cfgs = {}; } (filter (node: node != "config")(attrNames (readDir dir)))
  );

  result = mkModules ./.;

in
{
  options.modules.user = result.opts;
  config.modules.user = result.cfgs;
}
