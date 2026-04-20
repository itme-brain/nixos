{ config, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${config.user.name} = {
    imports = [
      ../../../../../user
      ../../../../../user/home.nix
      ../../../../../user/modules
    ];

    home.stateVersion = "25.11";

    # Machine-specific modules
    modules.user = {
      neovim.enable = false;
      vim.enable = true;
      tmux.enable = false;
    };
  };
}
