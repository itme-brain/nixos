"""Update Pillow's private Brotli ABI without changing its image/font features."""
import ctypes
from pathlib import Path
import shutil
import subprocess
import sysconfig

vendor = Path(sysconfig.get_path("platlib")) / "pillow.libs"
common, = vendor.glob("libbrotlicommon-*.so.*")
decoder, = vendor.glob("libbrotlidec-*.so.*")
for target, source in ((common, "libbrotlicommon.so.1"), (decoder, "libbrotlidec.so.1")):
    shutil.copyfile(Path("/opt/brotli-security/lib") / source, target)
    subprocess.run(["patchelf", "--set-soname", target.name, str(target)], check=True)
subprocess.run([
    "patchelf", "--replace-needed", "libbrotlicommon.so.1", common.name, str(decoder)
], check=True)
# Explicit RPATH also lets the build-time check resolve the private common lib.
subprocess.run(["patchelf", "--set-rpath", "$ORIGIN", str(decoder)], check=True)
for path in (decoder, Path("/usr/lib/x86_64-linux-gnu/libbrotlidec.so.1")):
    lib = ctypes.CDLL(str(path))
    lib.BrotliDecoderErrorString.restype = ctypes.c_char_p
    assert lib.BrotliDecoderErrorString(-17).endswith(b"BLOCK_SWITCH"), path
import _brotli
lib = ctypes.CDLL(_brotli.__file__)
lib.BrotliDecoderErrorString.restype = ctypes.c_char_p
assert lib.BrotliDecoderErrorString(-17).endswith(b"BLOCK_SWITCH")
print("Verified fixed Python, system and Pillow Brotli decoders")
