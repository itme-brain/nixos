# Clef Airy on rigby

Public UI: https://ai.ramos.codes/systemone/run

Authentication is enforced by server's Nginx and Authentik. Both LibreChat
and Airy use the same Authentik browser session; LibreChat additionally uses
its native OIDC integration. Both applications require membership in Authentik's
`AI users` group. GitHub self-enrollment is disabled, and all enrollment flows
are denied by the `Self-enrollment disabled` policy. Existing linked GitHub
accounts can still sign in; new accounts must be created by an administrator.

To grant access, open Authentik's Admin interface, go to Directory > Users,
create an internal user, set their password, and add them to `AI users`.
Do not add ordinary users to `authentik Admins`. Users can optionally link
GitHub from their Authentik user settings after signing in to their manually
created account; identifier matching prevents automatic email-based linking.
The owner `itme-brain` is an internal user in both groups.

The dashboard shows separate `LibreChat` and `Clef Airy` launchers. The shared
proxy application (`ai-browser`, named `AI website authentication`) is hidden
from the dashboard using `meta_hide`; it still protects both browser apps.
The `clef-airy` application is a providerless launcher to
`https://ai.ramos.codes/systemone/run` and also requires `AI users` membership.

Login branding matches `ramos.codes`: the original favicon, an icon extracted
from it, serif type, and plain light/dark backgrounds. Assets and the CSS source
are in `system/machines/server/modules/authentik/branding/`; Nginx serves the
assets at `https://auth.ramos.codes/branding/`. The default Authentik brand stores
the CSS in `branding_custom_css`, with absolute HTTPS logo/favicon URLs so
Authentik does not treat them as uploaded-media paths. Authentication flow
titles are `sign in`. These database settings are included in the normal dump.

The shared gateway's newly issued access tokens expire after five minutes;
already-issued tokens retain their original expiry. Revoke user sessions as
well as removing `AI users` membership when withdrawing access. The temporary
Authentik bootstrap administrator API token was revoked after provisioning;
new automation must use a separately created temporary administrator token.

The rigby gateway configuration is tracked in `external/rigby/gateway/nginx.conf`
and deployed to `/home/llama/gateway/nginx.conf`. Frontend routes accept only
server's LAN address, so reaching rigby's LAN port directly cannot bypass
Authentik. Inference and MCP still use the separately managed Bearer API key.

The security audit replaced LibreChat's published credential-encryption
defaults after backing up MongoDB and its environment. Its existing encrypted
plugin credential was re-encrypted and verified, and the credential fingerprint
marker was established after migration. JWT signing secrets were preserved.
Recovery files are root-only in
`/home/llama/backups/ai-stack/20261018-security-audit`.

Open audit items: Authentik does not require MFA for all login methods. Airy
shares its settings and saved requests between approved users; it is a trusted
playground rather than an isolated multi-user application. Dependency audits
also report advisories in LibreChat's production dependency tree and Airy's
build dependencies; the authentication restrictions do not replace security
updates for those packages.

LibreChat disables email login and email registration, and its direct GitHub
OAuth credentials are unset. `ALLOW_SOCIAL_REGISTRATION=true` is intentionally
retained for first-login profile creation through Authentik OIDC; access is
approved by Authentik before that profile can be created. Disabling it would
also block newly approved Authentik users from their first LibreChat login.

LibreChat's Authentik OIDC provider must allow `authorization_code` and
`refresh_token` grants. LibreChat uses `TRUST_PROXY=2` for server's Nginx and
rigby's gateway. The public `/oauth/` route must forward the public Host,
HTTPS scheme, and client IP as configured in the Authentik NixOS module;
otherwise secure state cookies and per-client login rate limits break.

The Authentik NixOS module is in
`system/machines/server/modules/authentik/default.nix`. Its service secrets,
including GitHub OAuth credentials, are SOPS-encrypted in
`secrets/system/authentik.env`. Authentik's application/provider configuration
is stored in its PostgreSQL database. The normal encrypted server backup
first makes a consistent database dump with `authentik-dump.service`.

## Airy deployment

- Upstream checkout: `/home/llama/servers/clef-airy`, commit
  `ed7cd282ae0b097eee9df2571b2d0c6ae66d7d1b`; kept unmodified.
- Unit: `/etc/systemd/system/clef-airy.service`, installed from this directory.
  All runtime flags are in the unit; no launch wrapper.
- Image: `clef-airy:ed7cd28-web-dark`, built on rigby from the Dockerfile here.
- Private encryption key: `/etc/clef-airy/app.env`, root:llama, mode 0640.
- SQLite database: `/home/llama/systemone/data/database.sqlite`.
- Laravel storage: `/home/llama/systemone/storage`.
- Backend: `127.0.0.1:3090`, reachable only through the local gateway.
- Inference: local Radiance d1 at `127.0.0.1:9333`, using the existing key.
  The saved key is encrypted in SQLite by Laravel's application key.
- Logs: `journalctl -u clef-airy` / `docker logs clef-airy`.

The gateway's `/systemone/` route accepts only server's LAN address,
`192.168.0.154`. Server performs authentication before forwarding requests.
Native inference clients continue using their existing Bearer key on `/v1/*`.

## Rebuild

Create a temporary build directory containing these deployment files and an
`app/` directory populated with `git archive` of the pinned upstream commit.
Then run `docker build -t clef-airy:ed7cd28-web-dark BUILD_DIRECTORY` on rigby.
Restart `clef-airy.service` after building. Keep SQLite, storage, and the
application encryption key when replacing the image.

`web-hosting.patch` trusts forwarded URL information from the local proxy,
allows an explicitly configured model/vision capability, and supports data-URL
images. `systemone.php` defines those environment settings. This is client
compatibility and subpath hosting; Radiance still receives native System One
requests without a translation gateway.

`dark-mode.patch` adds a header light/dark toggle, semantic colors for panels,
navigation, errors and buttons, and both light/dark JSON syntax palettes.
The preference defaults to the system theme and is saved per browser under
`clef-theme` in local storage. It is applied before rendering to avoid a bright
flash and follows system changes until a manual choice is made. The Dockerfile
applies the patch in both the asset build and runtime stages; no edits to the
upstream source checkout or manual changes inside the running container are
needed to preserve the feature.

## Recovery

Pre-migration LibreChat configuration and a MongoDB dump are retained on rigby
in `/home/llama/backups/ai-stack/20261018-authentik-airy`, accessible to root.
The original LibreChat account was changed from GitHub to OpenID so its email
can be used with Authentik; no conversations were deleted.

Authentik uses pinned 2026.8.4 server/worker images, a dedicated PostgreSQL 16
container, and localhost-only ports on server. Services start on boot through
NixOS OCI units. Its emergency administrator credentials are in the encrypted
environment file; they are separate from GitHub sign-in.
