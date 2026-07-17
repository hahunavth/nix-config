# AGENTS.md

Guidance for AI agents working in this repository (`CLAUDE.md` just includes this file).

macOS + NixOS system configuration: [nix-darwin](https://github.com/nix-darwin/nix-darwin) +
[home-manager](https://github.com/nix-community/home-manager), Nix Flakes.

- Host `KOD-ADMINs-MacBook-Pro` — Apple Silicon work Mac, user `kod_admin`
- Host `nixos` — headless OrbStack dev VM (`aarch64-linux`); host `nixos-desktop` — `x86_64-linux` GNOME VM
- Repo lives at `/etc/nix-darwin` (user-owned, no sudo to edit); inside the OrbStack VM the same
  checkout is mounted at `/private/etc/nix-darwin`

## Layout — each host OWNS its config

```
flake.nix                 # global `identity` + explicit host list (attr name = hostname)
hosts/<name>/             # per machine: default.nix (hostPlatform, hostName, its casks/system
                          #   config) + home.nix (its hn.* toggles + host-only home config)
lib/                      # mkDarwin/mkNixos builders (pure) + shared home-manager wiring
modules/
  home-shared/            # cross-platform home core, runs on every host:
    features.nix          #   hn.* FEATURE OPTIONS (declared here, enabled per host)
    programs/             #   per-program: git ssh zsh (+oh-my-zsh) starship neovim tmux direnv
                          #     fzf eza zoxide nh atuin mise maven atlassian-* secrets
    packages/ aliases/ scripts/ files.nix
  darwin/                 # macOS platform layer; homebrew/ (nix-homebrew + shared cask base),
                          #   home/ (macOS-only home modules), linux-builder (on by default)
  nixos/                  # NixOS platform layer; orbstack/ is GENERATED — do NOT hand-edit
pkgs/                     # custom packages (raycast-beta, atlassian-plugin-sdk)
shells/                   # dev shells: nix develop .#default|atlassian|node|python
secrets/                  # sops-nix scaffold; inert until a host sets hn.secrets.enable
.claude/commands/         # repo slash commands: /build /rebuild /add-host /add-cask
docs/                     # human runbooks + architecture
```

Nested `AGENTS.md` files document the non-obvious directories (`hosts/`, `lib/`, `pkgs/`,
`modules/nixos/orbstack/`, `modules/home-shared/programs/` — the Atlassian trio,
`modules/darwin/homebrew/`). **Read the one next to the files you're editing.**

## Where does X go?

- **GUI app** → Homebrew cask: `modules/darwin/homebrew/casks/*.nix` (all hosts) or
  `homebrew.casks` in `hosts/<name>/default.nix` (one host). Never nixpkgs for GUI apps.
- **CLI tool** → nix: `modules/home-shared/packages/*.nix`
- **Shell alias** → `modules/home-shared/aliases/<domain>.nix`, merged in `aliases/default.nix`
- **Program config** → `modules/home-shared/programs/<program>.nix`, imported in
  `modules/home-shared/default.nix`; macOS-only home module → `modules/darwin/home/`
- **Feature toggle** → declare `hn.*` in `modules/home-shared/features.nix`, gate the module with
  `lib.mkIf config.hn.<f>.enable`, enable per host in `hosts/<name>/home.nix`
- **System setting** → a `modules/darwin/` module (shared) or `hosts/<name>/default.nix` (one host);
  no typed nix-darwin option → `system.defaults.CustomUserPreferences."<domain>"`
- **Language runtime** → mise (`globalConfig` or per-project `.mise.toml`), NOT nix/homebrew
- **Secret / key** → `secrets/*.sops.yaml` via sops-nix
- **New machine** → `hosts/<name>/{default.nix,home.nix}` + list it in `flake.nix`
  (see docs/runbooks/add-a-host.md)

Feature-flag defaults: `hammerspoon` + `defaultBrowser` on for macOS; `atlassian`, `winTunnel`,
`secrets`, `atuin` off — a host opts in. `nix.linux-builder` is on by default (darwin);
a host may disable it.

## Commands

Build only (no changes, no sudo) — **always do this to verify before switching**:

```bash
nix build .#darwinConfigurations.KOD-ADMINs-MacBook-Pro.system
```

Apply to the system (the `rebuild` zsh alias runs exactly this):

```bash
sudo darwin-rebuild switch --flake /etc/nix-darwin
```

Editing this repo: `nix develop` (nixfmt, statix, deadnix, nil), `nix fmt`, `nix flake check`.

NixOS hosts: evaluate from the Mac with
`nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run`;
apply INSIDE the VM: `orb -m nixos sudo nixos-rebuild switch --flake /private/etc/nix-darwin#nixos`.

## Conventions & gotchas

- **Flakes only see git-tracked files** — `git add -A` new files before building or they're invisible.
- **`flake.lock` is tracked; builds are pure** — never pass `--impure`. Run `darwin-rebuild` as your
  user (not a root shell) so the lock file doesn't become root-owned.
- **`homebrew.onActivation.cleanup = "zap"`** — casks/brews not declared in nix get uninstalled on
  the next switch.
- **User identity lives in `hosts/`**, threaded as `userConfig` — never hardcode usernames/emails
  in modules.
- **stateVersion is intentionally pinned** (`system.stateVersion = 4`, `home.stateVersion = "26.05"`)
  — these record install-time defaults; do not "upgrade" them.
- **Verify by building**, and for home-manager changes inspect the generated files in the built
  `home-manager-generation`/`home-manager-files` store path (e.g. `.zshrc`).
- OrbStack VM: **sshd stays disabled** (OrbStack provides SSH: `orb -m nixos`, `ssh nixos@orb`);
  `modules/nixos/orbstack/` is generated — only `modules/nixos/configuration.nix` is hand-maintained.
- Comments in this repo are in English.

## macOS specifics

- **Some `system.defaults` need a logout/restart** (Dock/Finder/WindowManager, input sources) —
  a rebuild writes the plist but running processes only reread it at login.
- **First switch triggers one-time GUI permission prompts** (default-browser dialog, Input Source
  Pro accessibility, App Management) — approve manually; they can't be granted declaratively.
  Touch ID for sudo works from the second switch on.
- **Input methods**: ABC + Vietnamese (Telex) + Japanese (Kotoeri) are configured manually.
  Do NOT declare `AppleEnabledInputSources` via `CustomUserPreferences` — it overwrites the whole
  list and would wipe these IMEs.
- **Keyboard type (ANSI/ISO/JIS) is NOT a nix setting** — fix §/± vs `/~ confusion via macOS
  Keyboard Setup Assistant, not `hidutil` remaps.

## Dev toolchains

Runtimes come from **mise** (`modules/home-shared/programs/mise.nix`), not nix: Node LTS + pnpm 11
global; Java 25 (default), 17, and 8 installed — pick per project in `.mise.toml`. Python/data
science uses the `miniconda` cask (conda init goes through `programs.zsh`, never `conda init`).

**Atlassian Plugin SDK** is nix-pinned at stable paths (Homebrew's tap is broken — never use it):
`~/.local/share/atlassian-plugin-sdk/{8.2.7,9.1.1}/bin`. Pair 8.2.7 with Java 8 (`zulu-8`; Temurin
has no arm64 JDK 8) and 9.1.1 with Java 17 (`temurin-17`) per project:

```toml
[tools]
java = "temurin-17"
[env]
_.path = ["~/.local/share/atlassian-plugin-sdk/9.1.1/bin"]
```

`atlas-mise-enable` (run once per repo) installs git hooks that regenerate a gitignored
`.mise.local.toml` per branch: name contains `wiki_9` → Java 17 + SDK 9.1.1, else Java 8 + SDK 8.2.7
(rule: `NEW_STACK_PATTERN` in `modules/home-shared/scripts/atlassian-mise/atlas-mise-gen.sh`).
If `atlas-mvn` tries to write into the read-only SDK dir, set
`MAVEN_OPTS=-Dmaven.repo.local=$HOME/.m2/repository`. Full details:
`modules/home-shared/programs/AGENTS.md`.
