# Conventions & gotchas

The rules this repo follows, and the macOS quirks behind them. The agent-facing version is
[`AGENTS.md`](../AGENTS.md); for a matching error message, see [troubleshooting.md](troubleshooting.md).

## Repo rules

- **Flakes only see git-tracked files.** Run `git add -A` on new files before building. Otherwise
  they're invisible, and the error won't say why.
- **`flake.lock` is tracked and builds are pure.** Never pass `--impure`. Run `darwin-rebuild` as
  your own user, not from a root shell, so the lock file doesn't become root-owned.
- **`homebrew.onActivation.cleanup = "zap"`.** Any cask or brew that nix doesn't declare is
  uninstalled on the next switch. An app installed by hand won't survive it.
- **User identity is defined once in `flake.nix`** (`identity`) and reaches modules as
  `userConfig`. Never hardcode a username or email in a module.
- **stateVersion is pinned on purpose** (`system.stateVersion = 4`, `home.stateVersion = "26.05"`).
  These record install-time defaults; don't "upgrade" them.
- **Verify by building.** For home-manager changes, inspect the generated files in the built
  `home-manager-generation` / `home-manager-files` store path instead of trusting the nix source.
- **OrbStack VM**: sshd stays disabled, because OrbStack provides access (`orb -m nixos`,
  `ssh nixos@orb`). Only `modules/nixos/configuration.nix` is edited by hand;
  `modules/nixos/orbstack/` is generated.
- **Nested `AGENTS.md` files** document the non-obvious directories: `hosts/`, `lib/`, `pkgs/`,
  `modules/nixos/orbstack/`, `modules/home-shared/programs/`, `modules/darwin/homebrew/`. Read
  the one next to the files you're editing.
- Comments are in English. `nix fmt` (nixfmt) and statix/deadnix run in CI.

## macOS specifics

- **Some `system.defaults` need a logout or restart** (Dock, Finder, WindowManager, input
  sources). A rebuild writes the plist, but a running process only rereads it at login.
- **The first switch triggers one-time GUI permission prompts**: the default-browser dialog,
  Input Source Pro accessibility, App Management. Approve them by hand; they can't be granted
  declaratively. Touch ID for sudo works from the second switch on.
- **Input methods** (ABC, Vietnamese Telex, Japanese Kotoeri) are configured by hand. Do **not**
  declare `AppleEnabledInputSources` via `CustomUserPreferences`. It replaces the whole list and
  wipes them.
- **Keyboard type (ANSI/ISO/JIS) is not a nix setting.** Fix `§`/`±` vs `` ` ``/`~` confusion in
  the macOS Keyboard Setup Assistant, not with `hidutil` remaps.
- **No typed nix-darwin option?** Use `system.defaults.CustomUserPreferences."<domain>"`.

## Dev toolchains

- **Runtimes come from mise** ([`programs/mise.nix`](../modules/home-shared/programs/mise.nix)),
  not nix or Homebrew. Node LTS and pnpm are global; Java 25 (default), 17 and 8 are installed and
  picked per project in `.mise.toml`.
- **Python and data science** use the `miniconda` cask. conda init goes through `programs.zsh`;
  never run `conda init`.
- **Dev shells** ([`shells/`](../shells/README.md)) are for one-off, reproducible entry.
  Inside real projects, prefer mise.
- **Atlassian Plugin SDK** (work, behind `hn.atlassian`): nix-pinned at
  `~/.local/share/atlassian-plugin-sdk/{8.2.7,9.1.1}/bin`, paired with Java 8 and 17 respectively.
  `atlas-mise-enable` switches the pair per git branch. Full details are in
  [`modules/home-shared/programs/AGENTS.md`](../modules/home-shared/programs/AGENTS.md).
