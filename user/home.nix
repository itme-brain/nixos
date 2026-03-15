{ lib, pkgs, config, ... }:

let
  pass = pkgs.pass.withExtensions (exts: with exts; [
    pass-audit
    pass-otp
    pass-update
  ]);

in
{
  programs.home-manager.enable = true;

  home.username = config.user.name;
  home.homeDirectory = "/home/${config.user.name}";

  # Essential packages for all users
  home.packages = with pkgs; [
    pass
    wget curl fastfetch fd
    unzip zip rsync
    calc calcurse
    age
    sops
  ];

  programs.bash.shellAliases = {
    cal = "${pkgs.calcurse}/bin/calcurse";
    calendar = "${pkgs.calcurse}/bin/calcurse";
  };

  # Default modules for all users (machines can override with mkForce false)
  modules.user = {
    bash.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    neovim.enable = lib.mkDefault true;
    security.gpg.enable = lib.mkDefault true;
  };
}
