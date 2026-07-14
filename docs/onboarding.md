# Onboarding & runbook

Human-facing guide for setting up and living with this config. (For AI-assistant
guidance see [`../CLAUDE.md`](../CLAUDE.md); for the layout overview see
[`../README.md`](../README.md).)

## Fresh machine

nix-darwin manages Homebrew casks but can't install Homebrew or Nix itself, so a
new Mac needs a one-time bootstrap:

```bash
# 1. get the repo to the canonical location
sudo mkdir -p /etc/nix-darwin && sudo chown "$USER" /etc/nix-darwin
git clone <repo-url> /etc/nix-darwin

# 2. run the bootstrap (installs Xcode CLT, Homebrew, Nix, first rebuild)
/etc/nix-darwin/scripts/bootstrap.sh
```

`darwin-rebuild` auto-selects the `darwinConfigurations` entry matching the
machine's hostname. Adding a new machine = a new `hosts/<name>/` directory (it owns
its config) plus one line in `flake.nix` — see [runbooks/add-a-host.md](runbooks/add-a-host.md).

## Daily commands

| command | what it does |
|---|---|
| `rebuild` | `sudo darwin-rebuild switch --flake /etc/nix-darwin` |
| `win-on` / `win-off` / `win-status` | socat port forwards to the Windows box |
| `win-5005` / `win-5006` | switch local 5005 between remote 5005 / 5006 |
| `mise install` | fetch the tool versions for the current project |
| `atlas-mise-enable` | enable branch-based Java/SDK switching in a plugin repo |

Build without applying (no sudo): `nix build .#darwinConfigurations.<host>.system`.

## Git identity

Personal email is the default; any repo whose path contains a **`KOD`** folder
automatically uses the kodnet work email (via `programs.git.includes`). Check with
`git -C <repo> config user.email`.

## Manual steps nix can't do

- **GUI permission prompts** on first switch: Arc default-browser confirmation,
  Input Source Pro Accessibility, possible App Management.
- **Terminal font**: set to a Nerd Font (JetBrainsMono/FiraCode Nerd Font) or the
  starship powerline pills/logos won't render. iTerm2 renders them best.
- **Keyboard type** (ANSI/ISO/JIS): if the top-left key types `§/±` instead of
  `` `/~ ``, fix it in the macOS Keyboard Setup Assistant — not with a remap.
- **SSH key files**: hosts in `modules/home-shared/programs/ssh.nix` reference on-disk keys
  (`kod-work.pem`, `hahunavth`, `hahunavth_claude`, …) that aren't managed by nix —
  copy them from the old machine (or export from Bitwarden) and `chmod 600`.

## Troubleshooting

- **Prompt shows boxes instead of icons** → terminal font isn't a Nerd Font.
- **`atlas-version: command not found`** → it's only on PATH inside an
  `atlas-mise-enable`d plugin repo, and needs a JDK active (via mise).
- **`mise WARN missing: …`** → the project pins tool versions not installed; run
  `mise install` in that repo.
- **`--impure` demanded** → `flake.lock` must be git-tracked and user-owned.
