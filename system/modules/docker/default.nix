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

    # Socket-activate instead of starting dockerd eagerly. docker.socket ships
    # with moby, is already enabled (WantedBy=sockets.target) and declares
    # Triggers=docker.service, so the socket exists from early boot and the
    # first client that connects to /run/docker.sock starts dockerd. Dropping
    # multi-user.target keeps ~36s of dockerd startup out of the boot critical
    # path; the first `docker` command of a boot pays that startup cost once,
    # and dockerd then stays up until stopped manually or rebooted.
    systemd.services.docker.wantedBy = mkForce [ ];

    # Add docker package to system packages
    environment.systemPackages = with pkgs; [
      docker
      docker-compose
    ];

    # Add user to docker group
    users.users.${config.user.name}.extraGroups = [ "docker" ];
  };
}
