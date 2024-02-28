{ config, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${config.user.name} = {
    imports = [
      ../../../user
      ../../../user/modules
    ];

    programs.home-manager.enable = true;
    programs.bash.shellAliases = {
      nixup = "sudo nixos-rebuild switch --flake /etc/nixos/.#server";
    };

    home.stateVersion = "23.11";

    home.username = "${config.user.name}";
    home.homeDirectory = "/home/${config.user.name}";

    modules = {
      bash.enable = true;
      git.enable = true;
      gpg.enable = true;

      utils = {
        enable = true;
        vim.enable = true;
      };

      gui.enable = false;
    };
  };
}
