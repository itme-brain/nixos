{ config, pkgs, lib, ... }:

{

# DESKTOP 
  
  programs.sway.enable = true;
  
  environment.systemPackages = with pkgs; [  
    rofi-wayland
    grim
    slurp
    wl-clipboard

    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-utils

    fontconfig
    emote

    xwayland
  ];
  
  services.trezord = {
    enable = true;
  };

# CONSOLE

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

# FONTS
    
  fonts = {
    fonts = with pkgs; [
      terminus_font
      nerdfonts
      
      noto-fonts
      noto-fonts-cjk
      
      emojione
    ];
  };


# GPU DRIVERS

#    boot.initrd.kernelModules = [ "amdgpu" ]; #Uncomment for AMD

    hardware.nvidia.open = true; # Uncomment for nvidia open-source nouveau drivers

#  services.xserver.videoDrivers = [ "nvidia" ];                         # Uncomment    
#    hardware = {                                                        # this 
#      opengl.enable = true;                                             # codeblock
#      nvidia = {                                                        # for
#      package = config.boot.kernelPackages.nvidiaPackages.stable;       # NVIDIA
#      modesetting.enable = true;                                        # proprietary
#      };                                                                # driver
#    };                                                                  # support
}
