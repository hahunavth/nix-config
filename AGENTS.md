# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

macOS system configuration managed with [nix-darwin](https://github.com/nix-darwin/nix-darwin) and
[home-manager](https://github.com/nix-community/home-manager), using Nix Flakes. Primarily macOS
(`aarch64-darwin`, Apple Silicon), but the same flake also builds a headless **NixOS** dev host
(`aarch64-linux`) — see "Multi-platform" below. Structured to grow to more hosts/users.

- Host (macOS): `KOD-ADMINs-MacBook-Pro`; user `kod_admin`
- Host (NixOS): `nixos` — a headless OrbStack VM (`aarch64-linux`) for dev, SSH'd into from the Mac
- Location: `/etc/nix-darwin` (a shared system path; the directory is owned by the user, so editing
  needs no sudo). Keep it here rather than a home dir — the machine has multiple accounts (ABC,
  Vietnamese, Japanese input methods) and is intended for team/multi-machine reuse. Inside the
  OrbStack VM the same repo is reachable at `/private/etc/nix-darwin` (Mac virtiofs mount).

## Layout

Three layers: **hosts/** (data) → **lib/** (pure logic) → **modules/** (config
building blocks, grouped by scope). Assembled by `flake.nix`.

```
flake.nix                       # inputs + darwin/nixosConfigurations, packages, checks, devShells, apps, formatter
hosts/                          # LAYER 1 · DATA — one file per machine (+ optional `features`)
  default.nix                   #   registry: common + host list
  common.nix                    #   shared identity
  work.nix                      #   KOD work Mac      nixos.nix  # OrbStack dev VM
hosts.example.nix               # host template
lib/                            # LAYER 2 · LOGIC (pure — no config)
  hosts.nix                     #   validation/enrichment -> userConfig (threaded via specialArgs)
  mk-system.nix                 #   mkDarwin/mkNixos builders (keeps flake.nix thin)
  mk-home.nix                   #   shared home-manager wiring used by both builders
modules/                        # LAYER 3 · BUILDING BLOCKS (grouped by scope)
  shared/                       #   cross-platform home-manager ("shared core", runs on every host)
    default.nix                 #     shared module imports
    features.nix                #     hn.* FEATURE REGISTRY (per-host toggles; see below)
    files.nix                   #     static dotfiles (home.file / xdg.configFile)
    programs/                   #     per-program: git ssh zsh starship neovim tmux direnv nh atuin
                                #       mise maven atlassian-sdk atlassian-mise secrets (optional ones hn.*-gated)
    packages/                   #     categorized CLI packages: development.nix, system.nix
    aliases/                    #     shell aliases by domain (win-tunnel gated on features.winTunnel)
    scripts/                    #     shell scripts (atlassian-mise/)
  darwin/                       #   macOS SYSTEM (nix-darwin), imported by modules/darwin/default.nix
    configuration.nix nix-settings.nix misc-system.nix security.nix fonts.nix macos-defaults.nix
    linux-builder.nix           #     Linux build VM (gated on features.linuxBuilder, default on)
    raycast-beta.nix            #     Raycast Beta install activation
    homebrew/                   #     nix-homebrew wiring (default.nix) + lib.nix + taps/brews/casks + profiles/
    home/                       #     macOS-only HOME modules: default-browser, hammerspoon (+ shared core)
  nixos/                        #   Linux SYSTEM (NixOS)
    configuration.nix           #     our layer: flakes/GC, zsh default shell, lean system packages
    orbstack/                   #     OrbStack-GENERATED guest config, copied verbatim — DO NOT hand-edit
    home/                       #     linux-only HOME modules (+ shared core)
pkgs/                           # custom packages: raycast-beta, atlassian-plugin-sdk (fetchurl-pinned);
                                #   default.nix aggregates them for the flake packages/checks outputs
shells/                         # per-project dev shells (nix develop .#default|atlassian|node|python)
secrets/                        # sops-nix scaffold (.sops.yaml); inert until features.secrets = true
treefmt.nix / statix.toml       # `nix fmt` (treefmt) config + statix lint config
.github/workflows/check.yml     # CI: format, lint, eval all hosts, build darwin packages
.claude/commands/               # repo slash commands: /build /rebuild /add-host /add-cask
scripts/bootstrap.sh            # fresh-machine bootstrap; docs/ = human runbooks + architecture
```

`nix run .#build-switch` builds + switches the current machine's config (picks the
host by hostname).

### Feature flags (`hn.*`)

Optional user modules are gated by a per-host feature registry
(`modules/shared/features.nix`). A host sets flags in `hosts/<name>.nix`:

```nix
features = { atlassian = true; hammerspoon = false; secrets = true; };
```

Unset flags fall back to per-profile/platform defaults: `atlassian`+`winTunnel`
default on for the `work` profile; `hammerspoon`+`defaultBrowser` on for macOS;
`secrets`+`atuin` default **off** (opt-in). Consuming modules use
`lib.mkIf config.hn.<feature>.enable`. `linuxBuilder` is a darwin-side flag read
straight from `userConfig.features` (separate module system).

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

### Multi-platform (macOS + NixOS)

The flake partitions `hosts/` entries by their `system` field: `*-darwin` → `darwinConfigurations`,
`*-linux` → `nixosConfigurations`. `system` defaults to `aarch64-darwin`, so macOS hosts need no change.

The **NixOS dev host** is a headless OrbStack VM named `nixos` (`aarch64-linux`). It shares all
portable home-manager modules (git, zsh, mise, neovim, tmux, …); macOS-only pieces (Homebrew,
hammerspoon, default-browser, `UseKeychain`, `mactop`/`macpm`) are excluded or `isDarwin`-guarded.

```bash
# Evaluate the NixOS config from the Mac (eval only; building Linux needs the linux-builder):
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run

# Apply — run INSIDE the VM (the repo is mounted at /private/etc/nix-darwin via virtiofs).
# Builds natively (the VM is aarch64-linux); the `rebuild` alias runs exactly this:
orb -m nixos sudo nixos-rebuild switch --flake /private/etc/nix-darwin#nixos
```

Gotchas specific to the OrbStack VM:
- **sshd stays disabled** (`modules/nixos/orbstack/orbstack.nix`) — OrbStack provides SSH itself
  (`orb -m nixos`, `ssh nixos@orb`). Do not enable `services.openssh`.
- The `kod_admin` user + hostname + timezone + stateVersion (`25.11`) are owned by the copied
  OrbStack files; set the login shell via `users.defaultUserShell` (the user has `useDefaultShell`).
- `modules/nixos/orbstack/` is OrbStack-generated — if OrbStack rewrites `/etc/nixos/*` on the VM,
  re-copy and diff. Only `modules/nixos/configuration.nix` is hand-maintained.
- SSH private keys are plain files in the Mac's `~/.ssh` (not managed by nix); for outbound git
  over SSH from the VM, copy the needed key into the VM's `~/.ssh` too.

## Conventions & gotchas

- **Flakes only see git-tracked files** — `git add -A` new files before building or they're invisible.
- **`flake.lock` is tracked in git** — builds are pure; do NOT pass `--impure`. Only run
  `darwin-rebuild` as your user (not via a root shell) so the lock file doesn't become root-owned.
- **GUI apps go through Homebrew casks** (not nixpkgs) — add them to
  `modules/darwin/homebrew/casks/*.nix` (all profiles) or `extraCasks` in
  `modules/darwin/homebrew/profiles/<profile>.nix` (one profile). CLI tools go in
  `modules/shared/packages/*.nix`. `homebrew.onActivation.cleanup = "zap"` removes anything
  not listed. The Homebrew installation itself is managed by nix-homebrew.
- **User identity (name/emails) lives in `hosts/`**, threaded everywhere as `userConfig` — don't
  hardcode usernames/emails in modules.
- **stateVersion is intentionally pinned** (`system.stateVersion = 4`, `home.stateVersion = "26.05"`).
  Do not "upgrade" these — they record install-time defaults, not the current release.
- **Verify changes by building** and, for home-manager changes, inspecting the generated files under
  the built `home-manager-generation` store path (e.g. `.zshrc`, `.config/git/config`).
- Comments in this repo are in English.

## macOS specifics

- **Homebrew is managed by nix-homebrew** (`modules/darwin/homebrew/`): the installation itself is
  declarative (`autoMigrate = true` takes over an existing /opt/homebrew).
- **First `darwin-rebuild switch` triggers one-time GUI permission prompts** that cannot be granted
  declaratively — approve them manually:
  - Arc default browser: a "change default browser to Arc?" confirmation dialog (from
    `modules/darwin/home/default-browser.nix`, via `defaultbrowser`).
  - Input Source Pro: needs **Accessibility** permission (System Settings → Privacy & Security).
  - Possibly an **App Management** prompt (home-manager 26.05 copies GUI apps during activation).
- **Touch ID for sudo** (`modules/darwin/security.nix`) takes effect after the first switch; that
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

Language runtimes are managed by **mise** (`modules/shared/programs/mise.nix`), not global nix packages.
Global defaults live in `programs.mise.globalConfig`; per-project versions go in each repo's
`.mise.toml`. Versions resolve at `mise install` time (network), not at nix build time.

- **Node + pnpm**: Node LTS and pnpm 11 are the global defaults.
- **Java**: JDK 25 (default), 17, and 8 are all installed; pick per project.
- **Python / data science**: the `miniconda` Homebrew cask (conda), separate from mise. With a
  home-manager-managed `.zshrc`, add conda's init to `programs.zsh` rather than running `conda init`.

**Atlassian Plugin SDK** — both versions are pinned via nix (`pkgs/atlassian-plugin-sdk`,
instantiated per version in `modules/shared/programs/atlassian-sdk.nix`) and exposed at stable paths. Homebrew is NOT
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

Two commands (from `modules/shared/programs/atlassian-mise.nix`) switch the Java + SDK stack by git
branch, per project:

- `atlas-mise-enable` — run once inside an Atlassian plugin repo. Installs
  `post-checkout`/`post-merge`/`post-rewrite` hooks, gitignores `.mise.local.toml`, and generates it
  for the current branch.
- `atlas-mise-gen` — regenerates `.mise.local.toml` from the current branch (called by the hooks).

Branch rule: name contains **`wiki_9`** → Java 17 + SDK 9.1.1; otherwise → Java 8 + SDK 8.2.7. Edit
`NEW_STACK_PATTERN` in `modules/shared/scripts/atlassian-mise/atlas-mise-gen.sh` to change it. The generated
`.mise.local.toml` is a gitignored local override; the hook calls `atlas-mise-gen` off PATH, so run
`git` from a shell that has the home-manager profile.

## Adding things

- **New host**: add `hosts/<name>.nix` (`username`, `hostname`, `profile`, optional `system`
  + `features`) and register it in `hosts/default.nix`. `lib/hosts.nix` validates it (hostname
  format, profile/system whitelist, duplicates); `darwin-rebuild` auto-selects the entry matching the
  machine's hostname. `system` defaults to `aarch64-darwin`; `*-linux` routes to nixosConfigurations.
- **New system module**: add under `modules/darwin/` (or `modules/nixos/`) and import it in that
  platform's `default.nix`.
- **New shared home module**: add under `modules/shared/programs/` and import it in
  `modules/shared/default.nix`. macOS-only home module → `modules/darwin/home/` (imported by its
  `default.nix`).
- **New alias group**: add `modules/shared/aliases/<domain>.nix` and merge it in `aliases/default.nix`.
- **New profile package**: shared → `modules/darwin/homebrew/{taps,brews,casks}`; profile-only →
  `extraCasks`/`removeCasks` in `modules/darwin/homebrew/profiles/<profile>.nix`.
- **New per-host feature**: add to `modules/shared/features.nix` (`hn.*`), gate the module with
  `lib.mkIf`, set per host via `features = { … }`.
