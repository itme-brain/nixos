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

## Migrating to Yubikey

### 1. Generate a new age identity on Yubikey

```bash
# Insert Yubikey and run interactive setup
age-plugin-yubikey

# Follow prompts:
#   - Select slot (default: 1)
#   - Set PIN policy (default: once per session)
#   - Set touch policy (recommended: always)
#
# This generates a NEW key on the Yubikey - you will not know the private key.
# Save the identity to the keys directory:
age-plugin-yubikey --identity > src/user/config/keys/age/yubikey
```

The identity file only contains a *reference* to the Yubikey, not the private key.
It will be deployed to `~/.config/sops/age/keys.txt` on rebuild.

### 2. Update .sops.yaml with Yubikey public key

```bash
# Get the public key (age1yubikey1...)
age-plugin-yubikey --list

# Edit .sops.yaml and replace/add the key:
vim .sops.yaml
```

```yaml
keys:
  - &yubikey age1yubikey1q...  # your Yubikey public key

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *yubikey
```

### 3. Re-key all secrets against the new key

```bash
# This decrypts with your OLD key and re-encrypts with the NEW key
find secrets -name "*.yaml" -exec sops updatekeys {} \;
```

You'll need your old key available during this step.

### 4. Remove the old age key (optional)

```bash
# Once all secrets are re-keyed and tested:
# 1. Remove old key from .sops.yaml
# 2. Delete the old key file from the repo:
rm src/user/config/keys/age/local  # or whatever your test key was named
```

### 5. Test decryption with Yubikey

```bash
# Should prompt for Yubikey touch/PIN
sops -d secrets/system/wifi.yaml

# Test a full rebuild
sudo nixos-rebuild switch --flake .#desktop
```

If decryption works, your migration is complete.
