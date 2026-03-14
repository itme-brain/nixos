let
  mkModules = dir: isRoot:
    let
      entries = builtins.readDir dir;
      names = builtins.attrNames entries;

      excludedDirs = [ "config" "scripts" ];
      isSubmodule = path:
        builtins.pathExists "${path}/.git" &&
        builtins.readFileType "${path}/.git" == "regular";
      isModuleDir = path:
        builtins.pathExists path &&
        builtins.readFileType path == "directory" &&
        !(builtins.elem (builtins.baseNameOf path) excludedDirs) &&
        !(isSubmodule path);
      isModule = file: file == "default.nix";

    in
      builtins.concatMap (name:
        let
          path = "${dir}/${name}";
        in
          if isModuleDir path then
            mkModules path false
          else if isModule name && !isRoot then
            [ dir ]
          else
            []
      ) names;

in
{
  imports = mkModules ./. true;
}
