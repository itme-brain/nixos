# Secrets Management

```
secrets/
├── system/     # System-level secrets (WiFi, VPN, etc.)
└── user/       # User-level secrets (password-store, API keys, etc.)
```

## Prerequisites

Age identity files are stored in `src/user/config/keys/age/` and deployed automatically.

```bash
# For testing with a local key:
age-keygen > src/user/config/keys/age/local

# For Yubikey (see "Migrating to Yubikey" below):
age-plugin-yubikey --identity > src/user/config/keys/age/yubikey

# Add the public key to .sops.yaml in repo root
```

After rebuild, the identity is written to `~/.config/sops/age/keys.txt`.

## Adding Secrets

1. Create or edit a YAML file:
   ```bash
   vim secrets/system/example.yaml
   ```

2. Encrypt in place:
   ```bash
   sops -e -i secrets/system/example.yaml
   ```

3. Reference in NixOS config:
   ```nix
   sops.secrets."SECRET_NAME" = {
     sopsFile = path/to/example.yaml;
   };
   ```

## Editing Secrets

```bash
# Opens decrypted in $EDITOR, re-encrypts on save
sops secrets/system/wifi.yaml
```

## Viewing Secrets

```bash
# Decrypt to stdout
sops -d secrets/system/wifi.yaml
```

## Removing Secrets

1. Remove from NixOS config
2. Delete the encrypted file or remove the key from it via `sops`

## Re-keying (after adding/removing age keys)

```bash
# Update .sops.yaml with new keys, then:
sops updatekeys secrets/system/wifi.yaml
```
