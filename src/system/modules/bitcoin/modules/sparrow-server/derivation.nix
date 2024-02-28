{ pkgs, ... }:

with pkgs;
stdenv.mkDerivation rec {
  pname = "sparrow-server";
  version = "1.8.2";

  src = fetchurl {
    url = "https://github.com/sparrowwallet/sparrow/releases/download/${version}/sparrow-server-${version}-x86_64.tar.gz";
    sha256 = "16hyrf8j7mv3m1ry7r2k3w70yxbf6smgcm5d35xy2hjqfmahv65m";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/bin
  '';

  meta = {
    description = "Sparrow Server";
    homepage = "https://sparrowwallet.com/";
    license = stdenv.lib.licenses.mit;
    platforms = stdenv.lib.platforms.linux;
  };
}
