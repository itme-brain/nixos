with builtins;
let
  extractName = string:
    let
      metadata = [
        "pub" "public" "priv" "private"
        "key" "file" "." "_" "-" "pk"
      ];
    in
      replaceStrings metadata (builtins.map (_: "") metadata) string;

  constructKeys = dir: (
    listToAttrs (
      map (subdir: {
        name = subdir;
        value = listToAttrs (
          map (file: {
            name = extractName file;
            value = readFile "${dir}/${subdir}/${file}";
          }) (filter (node: (readDir "${dir}/${subdir}").${node} == "regular") (attrNames (readDir "${dir}/${subdir}")))
        );
      }) (filter (node: (readDir dir).${node} == "directory") (attrNames (readDir dir)))
    )
  );
in
  constructKeys ./.
