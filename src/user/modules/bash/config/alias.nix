{ lib }:

with lib;
mkForce
{
  cd = "cd -L";
  grep = "grep --color";
  tree = "eza --tree --icons=never";
  lt = "eza --tree --icons=never";
}
