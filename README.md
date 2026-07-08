# nix-darwin configuration

macOS system configuration managed with [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager).

## Structure

```
.
├── flake.nix                      # inputs + darwinConfigurations wiring
├── hosts/
│   └── KOD-ADMINs-MacBook-Pro/    # host-specific config (hostname, platform)
├── modules/
│   └── darwin/                    # system-level (nix-darwin) modules
│       ├── core.nix               # nix settings, system packages, zsh
│       ├── macos-defaults.nix     # Finder / Dock defaults
│       ├── homebrew.nix           # Homebrew casks (GUI apps)
│       └── raycast-beta.nix       # Raycast Beta install activation script
├── home/                          # user-level (home-manager) modules
│   ├── default.nix                # user identity, imports
│   ├── packages.nix               # CLI packages
│   └── mise.nix                   # mise (runtime version manager)
└── pkgs/
    └── raycast-beta/              # custom package: Raycast Beta DMG
```

## Rebuild

```
sudo darwin-rebuild switch --flake .
```

(`--impure` is no longer needed since `flake.lock` is tracked by git.)

Note: flakes only see files tracked by git — after adding new files, run
`git add -A` before rebuilding.

## Adding a new machine

Create `hosts/<new-hostname>/default.nix` and add a corresponding entry
under `darwinConfigurations` in `flake.nix`.
