{ lib ? import <nixpkgs>, config ? import <nixpkgs>, ... }:

with builtins;
let
  moduleType = "user";

  mkModules = dir: pathAcc: (
    foldl' (attrs: node:
      let
      path = "${dir}/${node}";
      accPath =
        if readFileType node == "directory" then
          if pathAcc == ""
            then node
          else if node != "modules"
            then "${pathAcc}.${node}"
          else
            pathAcc
        else
          "";
      in
      if node == "default.nix" && dir != ./. then
        let
        moduleOpts = {
          ${accPath} = {
            enable = lib.mkEnableOption "Enable ${accPath} module";
          };
        };
        moduleCfgs = {
          ${accPath} = lib.mkIf config.modules.${moduleType}.${accPath}.enable (import path);
        };
        in
        {
          opts = attrs.opts // moduleOpts;
          cfgs = attrs.cfgs // moduleCfgs;
        }
      else if readFileType path == "directory" then
        (mkModules path pathAcc // attrs)
      else
        attrs
    ) { opts = {}; cfgs = {}; } (filter (node: node != "config") (attrNames (readDir dir)))
  );

  result = mkModules ./.;

in
{
  options.modules.user = result.opts;
  config.modules.user = result.cfgs;
}
