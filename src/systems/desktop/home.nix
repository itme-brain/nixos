{ config, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${config.user.name} = {
    imports = [
      ../../user
      ../../modules/user
    ];

    programs.home-manager.enable = true;
    programs.bash.shellAliases = {
      nixup = "sudo nixos-rebuild switch --flake /etc/nixos/.#desktop";
    };

    home.stateVersion = "22.11";

    home.username = "${config.user.name}";
    home.homeDirectory = "/home/${config.user.name}";

    modules = {
      bash.enable = true;
      git.enable = true;
      gpg.enable = true;
      security.enable = true;

      utils = {
        enable = true;
        dev.enable = true;
        irc.enable = true;
        vim.enable = false;
      };

      gui = {
        enable = true;
        alacritty.enable = true;
        browsers.enable = true;
        corn.enable = true;
        fun.enable = true;
        neovim.enable = true;
        utils.enable = true;
        writing.enable = true;
      };
    };
  };
}
