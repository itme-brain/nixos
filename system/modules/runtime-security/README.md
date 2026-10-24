# Temporary upstream security releases

The inputs remain pinned to avoid unrelated infrastructure changes. This
module packages upstream Brotli 1.2.1 (the same source/hash as nixpkgs PR
577208) and NGINX 1.30.6. `system.replaceDependencies` grafts both stable and
unstable Brotli library outputs throughout the built system closure, covering
Immich's native addons and other HTTP clients without a full dependency rebuild.
The ABI and store-name lengths are compatible. Existing Node runtime overrides
remain necessary until the selected upstream Node and its shared dependencies
are all verified patched.

The desktop also replaces its 32-bit library output. The local copy of Nix's
replacement helper additionally rewrites hash-only references after full path
references: compiler string merging leaves truncated store paths in some
binaries, otherwise retaining an entire old dependency closure. Remove this
helper override with the temporary module after the upstream package update.

Build both configurations normally. Before any live activation, inspect
`switch-to-configuration dry-activate`: dependency grafting changes many unit
paths and a broad switch may restart DNS, networking and graphical services.
Stage using `nix-env -p /nix/var/nix/profiles/system --set SYSTEM_PATH` followed
by `SYSTEM_PATH/bin/switch-to-configuration boot`.

For the internet-facing services, `scripts/activate-security-units.py` at the
repository root can apply only `nginx.service`, `immich-server.service` and
`nix-daemon.service` from the built generation. The runtime drop-ins vanish
at reboot. Existing processes otherwise retain their loaded libraries; the
desktop needs a reboot to complete activation. Avoid restarting networking
or the graphical session during an interactive deployment.

Remove this module and the Brotli package override when both promoted inputs
provide fixed releases. Rebuild, verify the resulting native decoder, and
confirm no old library outputs remain in the runtime closure before removal.
