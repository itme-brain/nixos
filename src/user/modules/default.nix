{ lib, config, ... }:

let

moduleType = "user";

mkModules = dir: pathAcc: (
  builtins.listToAttrs (
    builtins.filter (x: x != null) (
      map (node:
      let
        path = dir + (if dir == ./. then null else "/") + node;
        acc = if pathAcc == "" then node else pathAcc + "." + node;
      in
        if lib.isDirectory path && node != "config" then
          if node != "modules" then {
            name = lib.baseNameOf path;
            value = {
              options.modules.user.${acc}.enable = lib.mkEnableOption "${moduleType}.${acc}";
              config = lib.mkIf config.modules.user.${acc} (import path);
            };
          } + (mkModules path acc)
          else
            mkModules path pathAcc
        else
          null
      )
    )
  ) (builtins.attrNames (builtins.readDir dir))
);

in
mkModules ./.
