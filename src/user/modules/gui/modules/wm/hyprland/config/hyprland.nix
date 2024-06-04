{ config, lib, pkgs, ... }:

with pkgs;
{
  enable = true;
  xwayland.enable = true;

  settings = {
    "$mod" = "ALT";
    "$terminal" = "${alacritty}";
    "$menu" = "${rofi} -show drun -show-icons -drun-icon-theme Qogir -font 'Noto Sans 14'";

    monitor = [
      "HDMI-A-1, 1920X1080, 0x0, 1"
      "DP-1, 1080x1920, 1920x0, 1, transform, 1"
    ];

    exec-once = [
      "waybar"
    ];

    bind = [
      "$mod, Enter, exec, $terminal"
      "$mod, q, killactive"

      "$mod, J, swapwindow, d"
      "$mod, K, swapwindow, u"
      "$mod, H, swapwindow, l"
      "$mod, L, swapwindow, r"

      "$mod, F, fullscreen"

      ", Print, exec, ${grim} ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png"
      "SHIFT, Print, exec, ${grim} -g \"$(${slurp})\" ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png"
      "$mod&SHIFT, F, exec, ${alacritty} -e sh -c 'EDITOR=nvim ${ranger}'"
      #''$mod&SHIFT, Print, exec, sh -c 'grim -g "$(swaymsg -t get_tree | jq -j '"'"'.. | select(.type?) | select(.focused).rect | "\(.x),\(.y) \(.width)x\(.height)"'"'"')" ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png'"''

      "$mod, D, exec, $menu"
      "$mod&SHIFT, D, exec, ${rofi} -modi emoji -show emoji"
    ] ++ ( builtins.concatLists (builtins.genList (
    x: let
      ws = let
        c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
    in
    [
      "$mod, ${ws}, workspace, ${toString (x + 1)}"
      "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
    ])
      10)
    );

    bindm = [
      "$mod, mouse:272, movewindow"
    ];

    windowrulev2 = [
      "float, title:(Android Emulator)"
    ];

    input = {
      kb_layout = "us";
      follow_mouse = 0;
      accel_profile = "flat";
      sensitivity = 0.65;
    };

    env = [
      "HYPRCURSOR_SIZE, 24"
      "GTK_THEME, Qogir"
    ];

    gaps_in = 10;
    border_size = 0;
    no_border_on_floating = true;
  };
}
