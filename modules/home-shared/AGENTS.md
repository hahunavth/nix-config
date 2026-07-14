# modules/home-shared — AGENTS.md

The **shared core**: home-manager configuration that runs on *every* host (macOS
and the NixOS VM). `default.nix` imports everything here; the platform home
entries ([`../darwin/home`](../darwin/home), [`../nixos/home`](../nixos/home)) pull
`../home-shared` in and add their platform-only extras.

```
default.nix     # imports features + files + packages/ + programs/
features.nix    # hn.* feature registry (options only; each host sets them in hosts/<name>/home.nix)
files.nix       # static dotfiles (home.file / xdg.configFile)
programs/       # per-program modules (git, zsh, mise, atlassian-*, …) — see programs/AGENTS.md
packages/       # categorized CLI packages (development.nix, system.nix)
aliases/        # shell aliases by domain (merged in zsh.nix)
scripts/        # shell scripts installed via home-manager (atlassian-mise/)
```

Rule of thumb: if config applies to all platforms it goes here; macOS-only home
config goes in `../darwin/home/`, Linux-only in `../nixos/home/`. System-level
config is never here — that's `../darwin/` and `../nixos/`.
