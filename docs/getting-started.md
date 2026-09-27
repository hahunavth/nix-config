# Getting started

Setting up a machine with this config, and the few steps nix can't do. For the layout, see
[architecture.md](architecture.md); for AI agents, see [`../AGENTS.md`](../AGENTS.md).

## Fresh machine

nix-darwin manages Homebrew casks but can't install Homebrew or Nix itself, so a
new Mac needs a one-time bootstrap:

```bash
# 1. get the repo to the canonical location
sudo mkdir -p /etc/nix-darwin && sudo chown "$USER" /etc/nix-darwin
git clone https://github.com/hahunavth/nix-config /etc/nix-darwin

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
| `hl-on` / `hl-off` / `hl-status` | socat port forwards to the Windows box |
| `hl-5005` / `hl-5006` | switch local 5005 between remote 5005 / 5006 |
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

See [troubleshooting.md](troubleshooting.md). Each entry there is headed by the error you'll see.
