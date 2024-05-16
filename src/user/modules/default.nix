{ lib, ... }:

with lib;
let
  # Function to list the contents of a directory
  listDir = dir: builtins.filter (path: builtins.pathExists (dir + "/" + path)) (builtins.readDir dir);

  # Function to generate Nix attribute sets for directories
  traverse = dir: pathList: {
    inherit dir;
    contents = builtins.foldl' (acc: path:
    let
      fullPath = dir + "/" + path;
      newPathList = pathList ++ [ path ];
      optionPath = builtins.concatStringsSep "." newPathList;
      cfgPath = builtins.concatStringsSep "." (["config" "modules" "user"] ++ newPathList);
    in
      if builtins.pathExists fullPath && builtins.isDirectory fullPath then
        if path == "modules" then
          acc // { "${path}" = traverse fullPath newPathList; }
        else
          acc
      else if path == "default.nix" then
        let
          userDefinedAttrs = builtins.evalFile fullPath;
        in
          acc // { "${builtins.head pathList}" = {
            enable = mkEnableOption "user.${optionPath}";
            config = mkIf (eval "${cfgPath}.enable") userDefinedAttrs;
          }; }
      else
        acc
    ) {} (listDir dir);
  };

  # Function to generate the entire options.modules.user attribute set
  mkModules = dir: {
    options.modules.user = traverse dir [];
  };
in
# Example usage
mkModules ./.
