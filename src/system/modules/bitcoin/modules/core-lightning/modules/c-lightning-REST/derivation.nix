{ pkgs, ... }:

with pkgs;
stdenv.mkDerivation rec {
  pname = "c-lightning-REST";
  version = "0.10.7";

  src = fetchurl {
    url = "https://github.com/Ride-The-Lightning/c-lightning-REST/archive/refs/tags/v${version}.tar.gz";
    sha256 = "1swg53vbacsrsgy79lni07dy2h44b0yf2kad7j4fv17az4gwnxk7";
  };

  buildInputs = with pkgs; [
    nodejs
  ];

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

  meta = {
    description = "c-lighting REST API";
    homepage = "https://github.com/Ride-The-Lightning/c-lightning-REST";
    license = stdenv.lib.licenses.mit;
    platforms = stdenv.lib.platforms.linux;
  };
}
