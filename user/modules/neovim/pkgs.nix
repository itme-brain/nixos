{ pkgs, ... }:

let
  # Essential LSPs for config files (project-specific LSPs go in devShells)
  lsp = with pkgs; [
    nixd
    lua-language-server
    marksman
    taplo
  ];

  lsp' = with pkgs.nodePackages; [
    vscode-langservers-extracted  # jsonls, html, cssls
    bash-language-server
    yaml-language-server
  ];

  extraPackages = with pkgs; [
    lazygit
    gcc
  ];

in
  extraPackages ++ lsp ++ lsp'
