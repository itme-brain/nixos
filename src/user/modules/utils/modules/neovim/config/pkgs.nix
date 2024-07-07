{ pkgs, ... }:

let
  lsp = with pkgs; [
    nil
    marksman
    sumneko-lua-language-server stylua
    nodePackages."@tailwindcss/language-server"
    ccls
  ];

  lsp' = with pkgs.nodePackages; [
    typescript-language-server
    vscode-langservers-extracted
    bash-language-server
    pyright
    vls
  ];

  extraPackages = with pkgs; [
    lazygit
    gcc
  ];

in
  extraPackages ++ lsp ++ lsp'
