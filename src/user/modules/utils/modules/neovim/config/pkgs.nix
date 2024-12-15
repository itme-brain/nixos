{ pkgs, ... }:

let
  lsp = with pkgs; [
    nil
    marksman
    sumneko-lua-language-server stylua
    nodePackages."@tailwindcss/language-server"
    pyright
    clang-tools
    rust-analyzer
    #arduino-language-server
  ];

  lsp' = with pkgs.nodePackages; [
    typescript-language-server
    vscode-langservers-extracted
    bash-language-server
    vls
  ];

  extraPackages = with pkgs; [
    lazygit
    gcc
  ];

in
  extraPackages ++ lsp ++ lsp'
