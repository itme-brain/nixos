{ lib }:

with lib;
{
  cd = "cd -L";
  grep = "grep --color";
  tree = "eza --tree --icons=never";
  lt = mkForce "eza --tree --icons=never";
}
