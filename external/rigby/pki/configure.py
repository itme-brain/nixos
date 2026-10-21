#!/usr/bin/env python3
"""Persist CA distrust for Ubuntu, retained Python tools, and AI containers.

Run as root after updating ca-certificates. Does not restart applications.
"""
import datetime
import os
from pathlib import Path
import re
import shutil
import subprocess

from cryptography import x509
import yaml

BLOCKED = {
    "AAA Certificate Services", "emSign ECC Root CA - G3",
    "emSign Root CA - C1", "emSign ECC Root CA - C3",
}
CERTS = Path("/etc/infra-pki/certs")
BACKUP = Path("/var/backups/infra-pki") / datetime.datetime.now(
    datetime.timezone.utc
).strftime("%Y%m%dT%H%M%SZ")
ENVIRONMENT = {
    "SSL_CERT_FILE": "/etc/ssl/certs/ca-certificates.crt",
    "SSL_CERT_DIR": "/etc/ssl/certs",
    "REQUESTS_CA_BUNDLE": "/etc/ssl/certs/ca-certificates.crt",
    "CURL_CA_BUNDLE": "/etc/ssl/certs/ca-certificates.crt",
    "AWS_CA_BUNDLE": "/etc/ssl/certs/ca-certificates.crt",
    "PIP_CERT": "/etc/ssl/certs/ca-certificates.crt",
    "UV_NATIVE_TLS": "true",
}


def backup(path):
    target = BACKUP / str(path).lstrip("/")
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, target)


def write(path, content):
    path = Path(path)
    if path.exists() and path.read_text() == content:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        backup(path)
    # Preserve ownership/mode, including user-owned deployment definitions.
    path.write_text(content)


def filtered(data):
    kept = []
    removed = 0
    for pem in re.findall(
        rb"-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----", data, re.S
    ):
        cert = x509.load_pem_x509_certificate(pem)
        names = cert.subject.get_attributes_for_oid(x509.NameOID.COMMON_NAME)
        if names and names[0].value in BLOCKED:
            removed += 1
        else:
            kept.append(pem + b"\n")
    if not kept:
        raise ValueError("Refusing to install an empty CA bundle")
    return b"".join(kept), removed


class TaggedSequence(list):
    def __init__(self, values, tag):
        super().__init__(values)
        self.tag = tag


class Loader(yaml.SafeLoader):
    pass


class Dumper(yaml.SafeDumper):
    pass


for tag in ("!override", "!reset"):
    Loader.add_constructor(
        tag, lambda loader, node: TaggedSequence(loader.construct_sequence(node), node.tag)
    )
Dumper.add_representer(
    TaggedSequence, lambda dumper, value: dumper.represent_sequence(value.tag, value)
)


def secure_service(service, bundles=(), node=False):
    volumes = service.setdefault("volumes", [])
    destinations = {"/etc/ssl/certs", *bundles}
    volumes[:] = [
        v for v in volumes
        if (v.split(":")[1] if isinstance(v, str) else v.get("target")) not in destinations
    ]
    volumes.append(f"{CERTS}:/etc/ssl/certs:ro")
    volumes.extend(f"{CERTS}/ca-certificates.crt:{p}:ro" for p in bundles)
    env = service.setdefault("environment", {})
    if isinstance(env, list):
        env = dict(item.split("=", 1) for item in env if "=" in item)
        service["environment"] = env
    env.update(ENVIRONMENT)
    if node:
        options = env.get("NODE_OPTIONS", "").split()
        options = [o for o in options if o not in ("--use-bundled-ca", "--use-system-ca")]
        if "--use-openssl-ca" not in options:
            options.append("--use-openssl-ca")
        env["NODE_OPTIONS"] = " ".join(options)


def compose(path, services):
    path = Path(path)
    doc = yaml.load(path.read_text(), Loader=Loader) if path.exists() else {"services": {}}
    for name, (bundles, node) in services.items():
        if name == "mcp-auth" and name not in doc.get("services", {}):
            continue
        secure_service(doc.setdefault("services", {}).setdefault(name, {}), bundles, node)
    write(path, yaml.dump(doc, Dumper=Dumper, sort_keys=False))


def secure_unit(name, bundles=()):
    path = Path("/etc/systemd/system") / (name + ".service")
    if not path.exists():
        return
    text = path.read_text()
    if "src=/etc/infra-pki/certs," in text:
        return
    mounts = [f"--mount type=bind,src={CERTS},dst=/etc/ssl/certs,readonly"]
    mounts += [
        f"--mount type=bind,src={CERTS}/ca-certificates.crt,dst={p},readonly"
        for p in bundles
    ]
    flags = " ".join(mounts + [f"--env {k}={v}" for k, v in ENVIRONMENT.items()])
    text = text.replace("--network host ", "--network host " + flags + " ")
    write(path, text)


def main():
    if os.geteuid() != 0:
        raise SystemExit("Run as root")
    BACKUP.mkdir(parents=True, mode=0o700)
    # Keep explicit policy across subsequent Ubuntu CA package refreshes.
    path = Path("/etc/ca-certificates.conf")
    filenames = {
        "mozilla/Comodo_AAA_Services_root.crt", "mozilla/emSign_ECC_Root_CA_-_G3.crt",
        "mozilla/emSign_Root_CA_-_C1.crt", "mozilla/emSign_ECC_Root_CA_-_C3.crt",
    }
    write(path, "\n".join(
        "!" + line if line in filenames else line
        for line in path.read_text().splitlines()
    ) + "\n")
    subprocess.run(["update-ca-certificates"], check=True)
    data = Path("/etc/ssl/certs/ca-certificates.crt").read_bytes()
    clean, removed = filtered(data)
    if removed:
        raise SystemExit("Host CA policy failed: blocked roots remain")
    CERTS.mkdir(parents=True, exist_ok=True)
    # Write through the inode: running containers bind this file read-only.
    (CERTS / "ca-certificates.crt").write_bytes(clean)
    for alias in ("cert.pem", "ca-bundle.crt"):
        target = CERTS / alias
        if not target.exists():
            target.symlink_to("ca-certificates.crt")
    write("/etc/ca-certificates/update.d/infra-pki", "#!/bin/sh\nset -eu\n"
          "cp /etc/ssl/certs/ca-certificates.crt /etc/infra-pki/certs/ca-certificates.crt\n")
    os.chmod("/etc/ca-certificates/update.d/infra-pki", 0o755)

    repaired = 0
    for base in ("/home", "/opt", "/usr/local/lib", "/usr/lib/python3/dist-packages"):
        for directory, dirs, files in os.walk(base):
            dirs[:] = [d for d in dirs if d not in {
                ".git", ".cache", "node_modules", "models", "output", "input", "backups",
            }]
            for name in files:
                if name != "cacert.pem":
                    continue
                path = Path(directory) / name
                clean, removed = filtered(path.read_bytes())
                if removed:
                    backup(path)
                    path.write_bytes(clean)
                    repaired += 1

    py = "/usr/local/lib/python3.12/site-packages"
    python_bundles = [f"{py}/certifi/cacert.pem", f"{py}/pip/_vendor/certifi/cacert.pem"]
    compose("/home/llama/web-search-mcp/docker-compose.override.yml", {
        "web-search-mcp": (python_bundles, False),
        "web-search-mcp-canary": (python_bundles, False),
        "crawl4ai": (python_bundles, True),
        "searxng": (["/usr/local/searxng/.venv/lib/python3.14/site-packages/certifi/cacert.pem"], False),
        "lfm": ([], False), "mcp-auth": ([], False), "valkey": ([], False),
    })
    if Path("/home/librechat/LibreChat/compose.radiance.yaml").exists():
        compose("/home/librechat/LibreChat/compose.radiance.yaml", {
            "api": ([], True), "mongodb": ([], False),
        })
    secure_unit("clef-airy", ["/app/vendor/nativephp/php-bin/cacert.pem"])
    secure_unit("llama-gateway")
    shell_env = {**ENVIRONMENT, "NODE_OPTIONS": "--use-openssl-ca"}
    write("/etc/profile.d/60-ca-trust.sh", "".join(
        f"export {k}='{v}'\n" for k, v in shell_env.items()
    ))
    write("/etc/systemd/system.conf.d/60-ca-trust.conf", "[Manager]\nDefaultEnvironment="
          + " ".join(f'"{k}={v}"' for k, v in shell_env.items()) + "\n")
    subprocess.run(["systemctl", "daemon-reload"], check=True)
    print(f"Configured container trust; repaired {repaired} host Python bundles. Backup: {BACKUP}")


if __name__ == "__main__":
    main()
