{ config, pkgs, lib, ... }:

{
  services.pipewire = {
    enable = true;
    audio.enable = true;

    wireplumber.enable = true;

    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
  ];
}
