{ pkgs, lib, ... }:
#TODO: Figure out how to symlink to the /var/lib/clightning/plugins directory

with pkgs;
stdenv.mkDerivation rec {
  pname = "c-lightning-REST";
  version = "0.10.7";

  src = fetchurl {
    url = "https://github.com/Ride-The-Lightning/c-lightning-REST/archive/refs/tags/v${version}.tar.gz";
    sha256 = "1swg53vbacsrsgy79lni07dy2h44b0yf2kad7j4fv17az4gwnxk7";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

  meta = with lib; {
    description = "REST APIs for Core Lightning written with node.js";
    homepage = "https://github.com/Ride-The-Lightning/c-lightning-REST";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
