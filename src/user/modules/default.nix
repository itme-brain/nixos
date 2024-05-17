{ lib ? import <nixpkgs>, config ? import <nixpkgs>, ... }:

with builtins;
let
  moduleType = "user";

  mkModules = dir: pathAcc: (
    trace "Processing dir: ${dir} with pathAcc: ${pathAcc}" (
    foldl' (attrs: node:
      let
      path = dir + "/" + node;
      accPath =
        if pathAcc == ""
          then node
        else if node != "modules"
          then pathAcc + "." + node
        else
          pathAcc;
      in
      if node == "modules" then
        trace "Entering modules dir: ${modules}" (mkModules path accPath // attrs)
      else
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
        trace "Processing node: ${node} at path: ${path} with accumulatedPath: ${accPath}"(
          mkModules path accPath // {
            opts = attrs.opts // moduleOpts;
            cfgs = attrs.cfg // moduleCfgs;
          })
    )) { opts = {}; cfgs = {}; } (filter (node: node != "config" && readFileType node == "directory")(attrNames (readDir dir)))
  );

  result = mkModules ./.;

in
{
  options.modules.user = result.opts;
  config.modules.user = result.cfgs;
}
