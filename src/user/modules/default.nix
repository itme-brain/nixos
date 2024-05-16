{ lib, config, ... }:

let

moduleType = "user";

mkModules = dir: pathAcc: (
  builtins.foldl' (acc: node:
    let
      path = dir + (if dir == ./. then null else "/") + node;
      accPath = if pathAcc == "" then node else pathAcc + "." + node;
    in
      if lib.isDirectory path && node != "config" then
        if node != "modules" then
          let
            moduleOptions = {
              ${accPath} = {
                enable = lib.mkEnableOption "${moduleType}.${accPath}";
              };
            };
            moduleConfig = {
              ${accPath} = lib.mkIf config.modules.${moduleType}.${accPath}.enable (import path);
            };
          in
            {
              options = acc // moduleOptions;
              config = acc // moduleConfig;
            } // (mkModules path accPath)
        else
          mkModules path accPath
      else
        acc
  ) { opts = {}; cfg = {}; } (builtins.attrNames (builtins.readDir dir))
);

result = mkModules ./.;

in
{
  options = { modules.user = result.options; };
  config = { modules.user = result.config; };
}
