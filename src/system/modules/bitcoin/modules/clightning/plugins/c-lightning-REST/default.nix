{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin.clightning.rest;
  cln = config.modules.system.bitcoin.clightning;

in
{ options.modules.system.bitcoin.clightning.rest = { enable = mkEnableOption "C-Lightning REST API Server"; };
  config = mkIf (cfg.enable && cln.enable) {
    nixpkgs.overlays = [
      (final: prev: {
        clightning-REST = prev.buildNpmPackage rec {
          pname = "c-lightning-rest";
          version = "0.10.7";
          src = prev.fetchFromGitHub {
            owner = "Ride-The-Lightning";
            repo = "c-lightning-REST";
            rev = "v${version}";
            hash = "sha256-Z3bLH/nqhO2IPE1N4TxYhEDh2wHR0nT801kztfYoj+s=";
          };

          npmDepsHash = "sha256-svt5hjhTriGhehxC36yGwrqcjax/9UqqVzxEhHnoM0M=";
          dontNpmBuild = true;

          meta = with lib; {
            description = "REST APIs for Core Lightning written with node.js ";
            homepage = "https://github.com/Ride-The-Lightning/c-lightning-REST";
            license = licenses.mit;
          };
        };
      })
    ];
  };
}
