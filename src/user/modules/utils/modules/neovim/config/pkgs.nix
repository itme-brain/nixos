{ pkgs, ... }:

let
  lsp = with pkgs; [
    nil nixfmt-rfc-style
    marksman shfmt
    sumneko-lua-language-server stylua
    haskell-language-server hlint
    nodePackages."@tailwindcss/language-server"
    dhall-lsp-server
  ];

  lsp' = with pkgs.nodePackages; [
    typescript-language-server
    vscode-langservers-extracted
    bash-language-server
    diagnostic-languageserver
    pyright
    purescript-language-server
    vls
  ];

  extraPackages = with pkgs; [
    lazygit
    gcc
  ];

in
  extraPackages ++ lsp ++ lsp'
