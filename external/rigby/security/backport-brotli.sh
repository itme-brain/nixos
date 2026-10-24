#!/usr/bin/env bash
# Temporary Ubuntu Noble backport until Canonical publishes its security update.
# Builds the original Ubuntu source with Google's 1.1.x security fix, retaining
# Ubuntu's packaging and ABI. A later Ubuntu package can supersede this version.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=l
cd /var/cache/infra-security
mkdir -p apt-lists/partial
cat > noble.sources <<'EOF'
Types: deb deb-src
URIs: https://archive.ubuntu.com/ubuntu
Suites: noble noble-updates noble-security
Components: main universe
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
apt_source=(-o Dir::Etc::sourcelist=/var/cache/infra-security/noble.sources -o Dir::Etc::sourceparts=- -o Dir::State::lists=/var/cache/infra-security/apt-lists)
apt-get "${apt_source[@]}" update -qq
apt-get "${apt_source[@]}" build-dep -y brotli
if [[ ! -d brotli-1.1.0 ]]; then
  apt-get "${apt_source[@]}" source brotli=1.1.0-2build2
fi
cd brotli-1.1.0
if ! grep -q BLOCK_SWITCH c/include/brotli/decode.h; then
  patch -p1 < /usr/local/lib/infra-security/brotli-CVE-2026-111497.patch
fi
if ! dpkg-parsechangelog -S Version | grep -q '+infra1$'; then
  python3 - <<'PY'
from pathlib import Path
from email.utils import formatdate
p = Path('debian/changelog')
p.write_text('brotli (1.1.0-2build2+infra1) noble; urgency=high\n\n'
             '  * Backport CVE-2026-111497 (google/brotli da980636).\n\n'
             ' -- Infrastructure Security <root@rigby>  ' + formatdate(localtime=True)
             + '\n\n' + p.read_text())
PY
fi
dpkg-buildpackage -b -uc -us -j4
cd ..
dpkg -i libbrotli1_1.1.0-2build2+infra1_amd64.deb python3-brotli_1.1.0-2build2+infra1_amd64.deb
ldconfig
python3 - <<'PY'
import ctypes, brotli, _brotli
lib = ctypes.CDLL('libbrotlidec.so.1')
lib.BrotliDecoderErrorString.restype = ctypes.c_char_p
assert lib.BrotliDecoderErrorString(-17).endswith(b'BLOCK_SWITCH')
python_lib = ctypes.CDLL(_brotli.__file__)
python_lib.BrotliDecoderErrorString.restype = ctypes.c_char_p
assert python_lib.BrotliDecoderErrorString(-17).endswith(b'BLOCK_SWITCH')
assert brotli.decompress(brotli.compress(b'check')) == b'check'
print('Ubuntu native/Python Brotli backport verified')
PY
