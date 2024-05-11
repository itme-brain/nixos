{ pkgs, ... }:

with pkgs;
stdenv.mkDerivation rec {
  pname = "sparrow-server";
  version = "1.9.0";

  src = fetchurl {
    url = "https://github.com/sparrowwallet/sparrow/releases/download/${version}/sparrow-server-${version}-x86_64.tar.gz";
    sha256 = "sha256-0vzgqjq208jwxfp83ss6rm08d0fd2jnph81gkkh13sg78xj2vqfc";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/bin
  '';

  meta = with lib; {
    description = "Desktop Bitcoin Wallet focused on security and privacy. Free and open source.";
    homepage = "https://sparrowwallet.com/";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
