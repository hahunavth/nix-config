# nix-darwin configuration

macOS system configuration managed with [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager).
Structure follows [mlgruby/dotfile-nix](https://github.com/mlgruby/dotfile-nix): a machine registry
(`hosts.nix`) plus profile-composed package lists (common base + work/personal overrides).

## Structure

```
.
├── flake.nix                      # inputs + darwinConfigurations from hosts.nix
├── hosts.nix                      # machine & identity registry (see hosts.example.nix)
├── lib/hosts.nix                  # hosts.nix validation & enrichment (userConfig)
├── darwin/                        # system-level (nix-darwin) modules
│   ├── configuration.nix          # base: packages, hostname, allowUnfree
│   ├── nix-settings.nix           # nix: flakes, GC, optimise, trusted-users
│   ├── misc-system.nix            # stateVersion, primaryUser, zsh
│   ├── security.nix               # Touch ID for sudo
│   ├── linux-builder.nix          # Linux build VM
│   ├── fonts.nix                  # Nerd Fonts
│   ├── macos-defaults.nix         # Finder / Dock defaults
│   ├── homebrew.nix               # nix-homebrew + composed package lists
│   ├── homebrew-packages/         # categorized casks/brews/taps lists
│   ├── profiles/                  # common + work/personal overrides
│   └── raycast-beta.nix           # Raycast Beta install activation script
├── home-manager/                  # user-level (home-manager) config
│   ├── default.nix                # module imports
│   ├── modules/                   # per-program modules (git, ssh, zsh, mise, ...)
│   │   └── packages/              # categorized CLI packages
│   ├── aliases/                   # shell aliases split by domain
│   └── scripts/                   # shell scripts installed via home-manager
├── pkgs/                          # custom packages (raycast-beta, atlassian-plugin-sdk)
├── scripts/bootstrap.sh           # fresh-machine bootstrap
└── docs/onboarding.md             # human runbook
```

## Rebuild

```
sudo darwin-rebuild switch --flake .
# or, after the first switch: `rebuild` / `rebuild2` (nh, with diff)
```

Note: flakes only see files tracked by git — after adding new files, run
`git add -A` before rebuilding.

## Adding things

- **A machine**: add an entry to `hosts.nix` (username, hostname, profile).
- **A GUI app**: add its cask to `darwin/homebrew-packages/casks/*.nix` (all
  profiles) or `extraCasks` in `darwin/profiles/<profile>.nix` (one profile).
- **A CLI tool**: add to `home-manager/modules/packages/*.nix`.
- **An alias**: add to `home-manager/aliases/*.nix`.
