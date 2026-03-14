{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  protobuf,
}:

rustPlatform.buildRustPackage rec {
  pname = "clnrest";
  version = "25.02.2";

  src = fetchFromGitHub {
    owner = "ElementsProject";
    repo = "lightning";
    rev = "v${version}";
    hash = "sha256-SiPYB463l9279+zawsxmql1Ui/dTdah5KgJgmrWsR2A=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  cargoBuildFlags = [
    "-p"
    "clnrest"
  ];
  cargoTestFlags = [
    "-p"
    "clnrest"
  ];

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];

  buildInputs = [ openssl ];

  postInstall = ''
    mkdir -p $out/libexec/c-lightning/plugins
    mv $out/bin/clnrest $out/libexec/c-lightning/plugins/
    rmdir $out/bin
  '';

  meta = {
    description = "Transforms RPC calls into REST APIs";
    homepage = "https://docs.corelightning.org/docs/rest";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "clnrest";
  };
}
