{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.docker;

in
{
  options.modules.system.docker = { enable = mkEnableOption "Enable Docker"; };
  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;

      # Explicit storage driver for ext4/xfs filesystems
      storageDriver = "overlay2";
    };

    # Add docker package to system packages
    environment.systemPackages = with pkgs; [
      docker
      docker-compose
    ];

    # Add user to docker group
    users.users.${config.user.name}.extraGroups = [ "docker" ];
  };
}
