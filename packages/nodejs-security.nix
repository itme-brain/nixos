{ lib, stdenv, fetchurl, python3, ninja, pkg-config, icu }:

# Keep the security release's bundled OpenSSL, c-ares and Brotli together.
# The pinned nixpkgs Node recipe otherwise links older shared libraries.
# TEMPORARY: retire this package once pinned nixpkgs supplies a verified patched
# Node runtime AND its shared dependencies. Restore the upstream Immich package,
# point Pi's private launcher at upstream Node, then remove this overlay/package.
# Keep Node out of Pi's home.packages; do not restore a global Node installation.
stdenv.mkDerivation (finalAttrs: {
  pname = "nodejs-security";
  version = "24.22.1";

  src = fetchurl {
    url = "https://nodejs.org/dist/v${finalAttrs.version}/node-v${finalAttrs.version}.tar.xz";
    hash = "sha256-T1N5eWKAza6wwvNY/QS2oWzE+336g7WoyRqdljtDUjE=";
  };

  nativeBuildInputs = [ python3 ninja pkg-config ];
  buildInputs = [ icu ];
  enableParallelBuilding = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;

  postPatch = ''
    patchShebangs configure tools
  '';
  configureFlags = [
    "--ninja"
    "--with-intl=system-icu"
    "--openssl-use-def-ca-store"
  ];
  postInstall = ''
    substituteInPlace \
      "$out/lib/node_modules/npm/bin/npm-cli.js" \
      "$out/lib/node_modules/npm/bin/npx-cli.js" \
      --replace-fail '#!/usr/bin/env node' "#!$out/bin/node"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/node" -e '
      const assert = require("node:assert/strict");
      const zlib = require("node:zlib");
      assert.equal(process.version, "v24.22.1");
      assert.equal(typeof zlib.constants.BROTLI_DECODER_ERROR_FORMAT_BLOCK_SWITCH, "number");
      assert.equal(zlib.brotliDecompressSync(zlib.brotliCompressSync(Buffer.from("check"))).toString(), "check");
    '
    readelf -h "$out/bin/node" | grep -q 'DYN (Position-Independent Executable file)'
    "$out/bin/npm" --version
    runHook postInstallCheck
  '';

  meta = {
    description = "Node.js security runtime with bundled dependency fixes";
    homepage = "https://nodejs.org/";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "node";
  };
})
