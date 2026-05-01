{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.neovim;

in
{ options.modules.user.neovim = { enable = mkEnableOption "user.neovim"; };
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraWrapperArgs = [
        "--suffix"
        "PATH"
        ":"
        "${config.home.homeDirectory}/.npm-global/bin"
      ];
      extraPackages = with pkgs; [
        gcc
        cargo
        rustc

        fzf
        fd
        ripgrep
        bat
      ];
    };

    home.file.".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink ./nvim;
      recursive = true;
    };
  };
}
