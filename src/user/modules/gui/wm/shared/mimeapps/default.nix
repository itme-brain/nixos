{ pkgs, lib, config, ... }:

let
  browser = config.programs;

  fileTypes = [ 
    "text/html" "application/pdf" "application/xml"
    "image/png" "image/svg+xml" "image/jpg" 
    "image/jpeg" "image/gif" "image/webp"
    "image/avif" "image/bmp" "image/tiff"
  ];

  defaultBrowser = if browser.firefox.enable then 
                     "firefox.desktop"
                   else if browser.brave.enable then
                     "brave-browser.desktop"
                   else if browser.chromium.enable then
                     "chromium.desktop"
                   else null;

in
{
  xdg.mimeApps = lib.optionalAttrs (defaultBrowser != null && config.xdg.portal.enable) {
    enable = true;
    defaultApplications = builtins.listToAttrs (
      map (type: { 
        name = type; 
        value = [ defaultBrowser ]; 
      }) fileTypes
    );
  };
}
