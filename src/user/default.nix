let
  mkModules = dir: isRoot:
    let
      entries = builtins.readDir dir;
      names = builtins.attrNames entries;
      
      isModuleDir = path: 
        builtins.pathExists path &&
        builtins.readFileType path == "directory" &&
        builtins.baseNameOf path != "config";
      isModule = file: file == "default.nix";
      isNix = file: builtins.match ".*\\.nix" file != null && file != "default.nix";

    in
      builtins.concatMap (name:
        let
          path = "${dir}/${name}";
        in
          if isModuleDir path then
            mkModules path false
          else if isModule name && !isRoot then
            [dir]
          else if isNix name then
            [path]
          else
            []
      ) names;

in
{
  imports = [
    ./config
  ] ++ mkModules ./. true;
}
