{ lib, config, ... }:

let
  programs = config.programs;

  defaultBrowser =
    if programs.firefox.enable then "firefox.desktop"
    else if programs.brave.enable then "brave-browser.desktop"
    else if programs.chromium.enable then "chromium.desktop"
    else null;

  types = [
    "text/html" "application/xhtml+xml"
    "x-scheme-handler/http" "x-scheme-handler/https"
    "application/pdf"
    "image/png" "image/jpeg" "image/jpg" "image/gif"
    "image/webp" "image/avif" "image/bmp" "image/tiff" "image/svg+xml"
    "video/mp4" "video/webm" "video/mkv" "video/avi"
    "video/x-matroska" "video/quicktime"
  ];

in
{
  xdg.mimeApps = lib.mkIf (defaultBrowser != null) {
    enable = true;
    defaultApplications = builtins.listToAttrs (
      map (t: { name = t; value = [ defaultBrowser ]; }) types
    );
  };
}
