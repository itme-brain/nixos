{ pkgs, ... }:

let
  lsp = with pkgs; [
    nil nixfmt
    marksman shfmt
    sumneko-lua-language-server stylua
    haskell-language-server hlint
    nodePackages."@tailwindcss/language-server"
  ];

  lsp' = with pkgs.nodePackages; [
    vscode-langservers-extracted
    typescript-language-server
    bash-language-server
    diagnostic-languageserver
    pyright
    volar
  ];

  extraPackages = with pkgs; [
    lazygit
    gcc
  ];

in
  extraPackages ++ lsp ++ lsp'
