{ lib }:

with builtins;
let
  extractName = filename:
    let
      # Remove .key extension
      noKey = lib.removeSuffix ".key" filename;
      # Remove .pub/.priv/.public/.private markers
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
            lib.hasSuffix ".key" file
          ) (attrNames (readDir "${dir}/${subdir}")))
        );
      }) (filter (node: (readDir dir).${node} == "directory") (attrNames (readDir dir)))
    )
  );
in
  constructKeys ./.
