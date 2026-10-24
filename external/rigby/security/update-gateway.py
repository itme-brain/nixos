"""Pin the existing gateway units to the verified official NGINX 1.30.6 image."""
from pathlib import Path
import shutil
import subprocess

old = 'nginx@sha256:dc5069ad14f19660b141b21236140b91656bf89bbc3e2417c70ae650cd66104c'
new = 'nginx@sha256:47928bf67eb62a1863cb08d9ecb52d3e704304ba614eaee17884204677702951'
backup = Path('/var/backups/infra-security-20261024/gateway')
for path in Path('/etc/systemd/system').rglob('*'):
    if not path.is_file() or path.is_symlink() or path.suffix not in ('.service', '.conf'):
        continue
    text = path.read_text()
    if old not in text:
        continue
    saved = backup / path.relative_to('/etc/systemd/system')
    saved.parent.mkdir(parents=True, exist_ok=True)
    if not saved.exists():
        shutil.copy2(path, saved)
    path.write_text(text.replace(old, new))
    print('Updated', path)
subprocess.run(['systemctl', 'daemon-reload'], check=True)
