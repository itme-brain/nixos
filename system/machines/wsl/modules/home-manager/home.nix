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

    home.stateVersion = "23.11";

    # Machine-specific modules
    modules.user = {
      utils = {
        dev.enable = true;
        email.enable = true;
        irc.enable = true;
      };
    };
  };
}
