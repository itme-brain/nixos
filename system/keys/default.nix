{ lib, ... }:

with lib;
with builtins;
let
  extractName = filename:
    let
      noKey = removeSuffix ".key" filename;
      noMarkers = replaceStrings
        [ ".pub" ".priv" ".public" ".private" ]
        [ "" "" "" "" ]
        noKey;
    in noMarkers;

  constructKeys = dir: (
    listToAttrs (
      map (subdir: {
        name = subdir;
        value = listToAttrs (
          map (file: {
            name = extractName file;
            value = readFile "${dir}/${subdir}/${file}";
          }) (filter (file:
            (readDir "${dir}/${subdir}").${file} == "regular" &&
            hasSuffix ".key" file
          ) (attrNames (readDir "${dir}/${subdir}")))
        );
      }) (filter (node: (readDir dir).${node} == "directory") (attrNames (readDir dir)))
    )
  );

in
{
  options = {
    machines = mkOption {
      description = "Machine Configurations";
      type = types.attrs;
      default = {
        keys = constructKeys ./.;
      };
    };
  };
}
