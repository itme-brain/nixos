{ lib, ... }:

with lib;
let

mkModules = dir: (
  listToAttrs (
    map (module: {
      name = module;
      value = if module == "default.nix" then
        import dir
      else mkModules "${dir}/${module}";
    })
  ) (builtins.attrNames (builtins.readDir dir))
);

in
{ options.modules.user = mkModules ./.; }
