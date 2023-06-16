{ pkgs, ... }:

let
  lsp = with pkgs; [
    nil nixfmt
    marksman shfmt
    sumneko-lua-language-server stylua
    haskell-language-server hlint
    nodePackages."@tailwindcss/language-server"
    dhall-lsp-server
  ];

  lsp' = with pkgs.nodePackages; [
    vscode-langservers-extracted 
    typescript-language-server 
    eslint
    bash-language-server 
    diagnostic-languageserver
    pyright 
    purescript-language-server
  ];
  
  debug = with pkgs; [
    haskellPackages.haskell-debug-adapter
  ];
in
  lsp ++ lsp' ++ debug
