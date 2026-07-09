# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

macOS system configuration managed with [nix-darwin](https://github.com/nix-darwin/nix-darwin) and
[home-manager](https://github.com/nix-community/home-manager), using Nix Flakes. macOS-only
(`aarch64-darwin`, Apple Silicon). Single host, single user today, but structured to grow.

- Host: `KOD-ADMINs-MacBook-Pro`
- User: `kod_admin`
- Location: `/etc/nix-darwin` (a shared system path; the directory is owned by the user, so editing
  needs no sudo). Keep it here rather than a home dir — the machine has multiple accounts (ABC,
  Vietnamese, Japanese input methods) and is intended for team/multi-machine reuse.

## Layout

Structure follows [mlgruby/dotfile-nix](https://github.com/mlgruby/dotfile-nix): a validated machine
registry (`hosts.nix` → `userConfig`) plus profile-composed Homebrew lists.

```
flake.nix                       # inputs + darwinConfigurations (one per hosts.nix host), devShell, formatter
hosts.nix                       # machine & identity registry; validated by lib/hosts.nix
hosts.example.nix               # template for hosts.nix
lib/hosts.nix                   # validation/enrichment -> userConfig (threaded via specialArgs)
darwin/                         # system-level (nix-darwin) modules, each imported by flake.nix
  configuration.nix             # base: system packages, hostname (from userConfig), allowUnfree
  nix-settings.nix              # nix: flakes, GC, optimise, trusted-users
  misc-system.nix               # stateVersion, primaryUser, users.users, zsh
  security.nix                  # Touch ID for sudo
  linux-builder.nix             # Linux build VM (aarch64-linux)
  fonts.nix                     # Nerd Fonts (JetBrainsMono, FiraCode)
  macos-defaults.nix            # Finder / Dock defaults
  homebrew.nix                  # nix-homebrew + composed package lists (do not edit lists here)
  homebrew-packages/            # categorized lists: taps.nix, brews/, casks/{apps,development,system}.nix
  profiles/                     # common.nix (shared) + work/personal.nix overrides (mkProfile in lib.nix)
  lib/homebrew.nix              # composeList/unique/removeItems helpers
home-manager/                   # user-level config
  default.nix                   # module imports (identity is set by the flake from userConfig)
  modules/                      # per-program: git, ssh, zsh, starship, neovim, tmux, direnv, nh,
                                #   mise, atlassian-sdk, atlassian-mise, default-browser
  modules/packages/             # categorized CLI packages: development.nix, system.nix
  aliases/                      # shell aliases by domain: core.nix, win-tunnel.nix (merged in zsh.nix)
  scripts/                      # shell scripts (atlassian-mise/)
pkgs/                           # custom packages: raycast-beta, atlassian-plugin-sdk (fetchurl-pinned)
scripts/bootstrap.sh            # fresh-machine bootstrap; docs/onboarding.md = human runbook
```

## Commands

Build only (no changes, no sudo) — always do this to verify before switching:
```bash
nix build .#darwinConfigurations.KOD-ADMINs-MacBook-Pro.system
```

Apply to the system:
```bash
sudo darwin-rebuild switch --flake /etc/nix-darwin
# after the first switch, the `rebuild` zsh alias runs exactly this
```

Dev shell / formatting (for editing this repo):
```bash
nix develop      # nixfmt, statix, deadnix, nil
nix fmt          # format all .nix files
nix flake check
```

## Conventions & gotchas

- **Flakes only see git-tracked files** — `git add -A` new files before building or they're invisible.
- **`flake.lock` is tracked in git** — builds are pure; do NOT pass `--impure`. Only run
  `darwin-rebuild` as your user (not via a root shell) so the lock file doesn't become root-owned.
- **GUI apps go through Homebrew casks** (not nixpkgs) — add them to
  `darwin/homebrew-packages/casks/*.nix` (all profiles) or `extraCasks` in
  `darwin/profiles/<profile>.nix` (one profile). CLI tools go in
  `home-manager/modules/packages/*.nix`. `homebrew.onActivation.cleanup = "zap"` removes anything
  not listed. The Homebrew installation itself is managed by nix-homebrew.
- **User identity (name/emails) lives in `hosts.nix`**, threaded everywhere as `userConfig` — don't
  hardcode usernames/emails in modules.
- **stateVersion is intentionally pinned** (`system.stateVersion = 4`, `home.stateVersion = "26.05"`).
  Do not "upgrade" these — they record install-time defaults, not the current release.
- **Verify changes by building** and, for home-manager changes, inspecting the generated files under
  the built `home-manager-generation` store path (e.g. `.zshrc`, `.config/git/config`).
- Comments in this repo are in English.

## macOS specifics

- **Homebrew is managed by nix-homebrew** (`darwin/homebrew.nix`): the installation itself is
  declarative (`autoMigrate = true` takes over an existing /opt/homebrew).
- **First `darwin-rebuild switch` triggers one-time GUI permission prompts** that cannot be granted
  declaratively — approve them manually:
  - Arc default browser: a "change default browser to Arc?" confirmation dialog (from
    `home-manager/modules/default-browser.nix`, via `defaultbrowser`).
  - Input Source Pro: needs **Accessibility** permission (System Settings → Privacy & Security).
  - Possibly an **App Management** prompt (home-manager 26.05 copies GUI apps during activation).
- **Touch ID for sudo** (`darwin/security.nix`) takes effect after the first switch; that
  first switch still needs a typed password.
- **Some settings need a logout/restart** to apply — most `system.defaults`, Dock/Finder changes,
  and any input-source changes. A rebuild alone may not visibly update them.
- **Keyboard type (ANSI/ISO/JIS) is NOT a nix setting** — it's per-hardware, set via macOS Keyboard
  Setup Assistant ("Change Keyboard Type…"). A misdetected type causes the §/± vs `/~ key confusion;
  fix it there, not with a `hidutil`/`remapTilde` remap (those treat the symptom and reset on reboot).
- **Input methods**: this machine uses ABC (US) plus Vietnamese (Telex) and Japanese (Kotoeri).
  Do NOT declare `AppleEnabledInputSources` via `CustomUserPreferences` — it overwrites the whole
  list and would wipe these IMEs.
- **For macOS settings without a typed nix-darwin option**, use
  `system.defaults.CustomUserPreferences."<domain>" = { ... }` (maps to `defaults write`).

## Dev toolchains

Language runtimes are managed by **mise** (`home-manager/modules/mise.nix`), not global nix packages.
Global defaults live in `programs.mise.globalConfig`; per-project versions go in each repo's
`.mise.toml`. Versions resolve at `mise install` time (network), not at nix build time.

- **Node + pnpm**: Node LTS and pnpm 11 are the global defaults.
- **Java**: JDK 25 (default), 17, and 8 are all installed; pick per project.
- **Python / data science**: the `miniconda` Homebrew cask (conda), separate from mise. With a
  home-manager-managed `.zshrc`, add conda's init to `programs.zsh` rather than running `conda init`.

**Atlassian Plugin SDK** — both versions are pinned via nix (`pkgs/atlassian-plugin-sdk`,
instantiated per version in `home-manager/modules/atlassian-sdk.nix`) and exposed at stable paths. Homebrew is NOT
used — its tap has broken formula class names and the `atlas-*` binaries collide on link.
- **8.2.7** at `~/.local/share/atlassian-plugin-sdk/8.2.7/bin` (pair with Java 8).
- **9.1.1** at `~/.local/share/atlassian-plugin-sdk/9.1.1/bin` (pair with Java 17).

Select one per project in `.mise.toml`, paired with its JDK:

```toml
# older Server/DC plugin project (SDK 8.2.7 + Java 8)
[tools]
java = "zulu-8"   # Temurin has no arm64 JDK 8 on Apple Silicon
[env]
_.path = ["~/.local/share/atlassian-plugin-sdk/8.2.7/bin"]
```

```toml
# newer plugin project (SDK 9.1.1 + Java 17)
[tools]
java = "temurin-17"
[env]
_.path = ["~/.local/share/atlassian-plugin-sdk/9.1.1/bin"]
```

The SDKs live in the read-only nix store, so if `atlas-mvn` fails trying to write into the SDK dir,
point Maven's local repo at a writable path (e.g.
`export MAVEN_OPTS=-Dmaven.repo.local=$HOME/.m2/repository`). Run `mise install` after editing versions.

### Branch-based auto-switching (Atlassian plugin repos)

Two commands (from `home-manager/modules/atlassian-mise.nix`) switch the Java + SDK stack by git
branch, per project:

- `atlas-mise-enable` — run once inside an Atlassian plugin repo. Installs
  `post-checkout`/`post-merge`/`post-rewrite` hooks, gitignores `.mise.local.toml`, and generates it
  for the current branch.
- `atlas-mise-gen` — regenerates `.mise.local.toml` from the current branch (called by the hooks).

Branch rule: name contains **`wiki_9`** → Java 17 + SDK 9.1.1; otherwise → Java 8 + SDK 8.2.7. Edit
`NEW_STACK_PATTERN` in `home-manager/scripts/atlassian-mise/atlas-mise-gen.sh` to change it. The generated
`.mise.local.toml` is a gitignored local override; the hook calls `atlas-mise-gen` off PATH, so run
`git` from a shell that has the home-manager profile.

## Adding things

- **New host**: add an entry to `hosts.nix` (`username`, `hostname`, `profile`). `lib/hosts.nix`
  validates it (hostname format, profile whitelist, duplicates); `darwin-rebuild` auto-selects the
  entry matching the machine's hostname. Note the flake hardcodes `system = "aarch64-darwin"`.
- **New system module**: add under `darwin/` and import it in `flake.nix`'s modules list.
- **New home module**: add under `home-manager/modules/` and import it in `home-manager/default.nix`.
- **New alias group**: add `home-manager/aliases/<domain>.nix` and merge it in `aliases/default.nix`.
- **New profile package**: shared → `darwin/homebrew-packages/`; profile-only → `extraCasks`/
  `removeCasks` in `darwin/profiles/<profile>.nix`.
