#!/usr/bin/env python3
"""Activate selected built service commands without a broad NixOS live switch.

First stage the built generation with switch-to-configuration boot. These
runtime drop-ins disappear at reboot, when the staged declarative units load.
Usage (root): activate-security-units.py SYSTEM_PATH UNIT.service [...]
"""
from pathlib import Path
import subprocess
import sys

system = Path(sys.argv[1]).resolve()
allowed = {'nginx.service', 'immich-server.service', 'nix-daemon.service'}
keys = {'Environment', 'ExecStart', 'ExecStartPre', 'ExecStartPost',
        'ExecStop', 'ExecStopPost', 'ExecReload'}
for unit in sys.argv[2:]:
    if unit not in allowed:
        raise SystemExit(f'Unsupported unit: {unit}')
    lines = (system / 'etc/systemd/system' / unit).read_text().splitlines()
    section = ''
    settings = []
    for line in lines:
        if line.startswith('['):
            section = line
        elif section == '[Service]' and line.split('=', 1)[0] in keys:
            settings.append(line)
    if not any(x.startswith('ExecStart=') for x in settings):
        raise SystemExit(f'No ExecStart in {unit}')
    dropin = Path('/run/systemd/system') / (unit + '.d/90-infra-security.conf')
    dropin.parent.mkdir(parents=True, exist_ok=True)
    previous = dropin.read_bytes() if dropin.exists() else None
    dropin.write_text('[Service]\n' + ''.join(k + '=\n' for k in sorted(keys))
                      + '\n'.join(settings) + '\n')
    subprocess.run(['systemctl', 'daemon-reload'], check=True)
    try:
        subprocess.run(['systemctl', 'restart', unit], check=True)
        subprocess.run(['systemctl', 'is-active', '--quiet', unit], check=True)
    except subprocess.CalledProcessError:
        if previous is None:
            dropin.unlink()
        else:
            dropin.write_bytes(previous)
        subprocess.run(['systemctl', 'daemon-reload'], check=True)
        subprocess.run(['systemctl', 'restart', unit], check=True)
        raise
    print('Activated', unit, 'from', system)
