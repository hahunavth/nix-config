# modules/shared/programs — AGENTS.md

Per-program user configuration in the cross-platform "shared core". Each file is
imported by [`../default.nix`](../default.nix) (`modules/shared/default.nix`), which
is in turn pulled in by both platform home entries (`modules/darwin/home`,
`modules/nixos/home`). Platform-specific bits are guarded with `pkgs.stdenv.isDarwin`.

## The Atlassian trio (the trap — read before touching)

These three interlock and are **work-specific**. Order matters.

- **`atlassian-sdk.nix`** — installs both Atlassian Plugin SDK versions from the
  nix store at stable paths (`~/.local/share/atlassian-plugin-sdk/{8.2.7,9.1.1}/bin`).
  The derivations live in [`../../../pkgs/atlassian-plugin-sdk`](../../../pkgs/atlassian-plugin-sdk).
  **Homebrew is deliberately NOT used** — its tap has broken formula class names and
  the `atlas-*` binaries collide on link.
- **`atlassian-mise.nix`** — installs `atlas-mise-enable` / `atlas-mise-gen`, which
  switch Java + SDK **per git branch** via `post-checkout`/`post-merge`/`post-rewrite`
  hooks. The branch→stack rule lives in `NEW_STACK_PATTERN` inside
  [`../scripts/atlassian-mise/atlas-mise-gen.sh`](../scripts/atlassian-mise/atlas-mise-gen.sh)
  (`wiki_9` → Java 17 + SDK 9.1.1; else Java 8 + SDK 8.2.7). It writes a gitignored
  `.mise.local.toml`.
- **`maven.nix`** — Maven config. The SDKs are in the read-only nix store, so point
  `maven.repo.local` at a writable path (`MAVEN_OPTS=-Dmaven.repo.local=$HOME/.m2/repository`)
  if `atlas-mvn` tries to write into the SDK dir.

Java runtimes themselves come from **mise** (`mise.nix`), not nix — see
[`../../../AGENTS.md`](../../../AGENTS.md) "Dev toolchains".

## Other gotchas

- **`git.nix`** — identity comes from `userConfig` (never hardcode). Repos under a
  `KOD` folder use the work email via `programs.git.includes`.
- **`ssh.nix`** — references on-disk private keys **not** managed by nix (today).
  These are the migration target for sops-nix (see `secrets.nix` + docs/runbooks/secrets.md).
- **macOS-only home modules** (`default-browser.nix`, `hammerspoon.nix`) do **not**
  live here — they're in [`../../darwin/home/`](../../darwin/home), imported only on macOS.
