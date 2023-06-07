{ pkgs, lib, ... }:

let
  theme = import ./theme;
  treesitter = import ./treesitter;
  editing = import ./editing;
  lsp = import ./lsp;
  luasnip = import ./luasnip;
  tools = import ./tools;

in
builtins.concatMap (dir: dir { inherit pkgs lib; }) [
  theme
  treesitter
  editing
  lsp
  luasnip
  tools
]
