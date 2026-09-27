# nix-config

Declarative macOS + NixOS setup: [nix-darwin](https://github.com/nix-darwin/nix-darwin),
[home-manager](https://github.com/nix-community/home-manager) and Nix Flakes. Per-host configs,
feature toggles, Homebrew casks, mise runtimes, dev shells and sops secrets.

[![check](https://github.com/hahunavth/nix-config/actions/workflows/check.yml/badge.svg)](https://github.com/hahunavth/nix-config/actions/workflows/check.yml)
[![built with nix](https://img.shields.io/badge/built_with-nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![nixpkgs 26.05](https://img.shields.io/badge/nixpkgs-26.05-7EBAE4?logo=nixos&logoColor=white)](https://github.com/NixOS/nixpkgs)
![platforms](https://img.shields.io/badge/platforms-aarch64--darwin%20%7C%20aarch64--linux%20%7C%20x86__64--linux-lightgrey)

This is my personal configuration for one Apple Silicon Mac and two NixOS VMs. It is not a
framework. Read it, borrow from it, but don't clone it and switch. If you are new to Nix, start
from [nix-darwin-kickstarter](https://github.com/ryan4yin/nix-darwin-kickstarter) or
[nix-starter-configs](https://github.com/Misterio77/nix-starter-configs) instead.

## Highlights

- **Each host owns its config**: everything unique to a machine lives in
  [`hosts/<name>/`](hosts/). There is no global config with per-host exceptions.
- **Feature toggles**: optional behaviour is declared once as an `hn.*` option in
  [`features.nix`](modules/home-shared/features.nix) and switched on per host.
- **Managed Homebrew**: GUI apps are casks, declared in nix via
  [nix-homebrew](https://github.com/zhaofengli-wip/nix-homebrew)
  ([`modules/darwin/homebrew/`](modules/darwin/homebrew/)). `cleanup = "zap"` uninstalls
  anything that isn't declared.
- **One shell everywhere**: zsh, starship, git, neovim, tmux and friends come from a
  platform-agnostic home core ([`modules/home-shared/`](modules/home-shared/)), identical on the
  Mac and both VMs.
- **Runtimes via mise**: Node, Java and friends are pinned per project in `.mise.toml`, not
  baked into the system ([`programs/mise.nix`](modules/home-shared/programs/mise.nix)).
- **Dev shells**: `nix develop .#node|python|atlassian|…` for one-off work ([`shells/`](shells/)).
- **Secrets**: sops-nix with age, scaffolded and off until a host opts in ([`secrets/`](secrets/)).
- **CI**: format (treefmt/nixfmt), lint (statix, deadnix), evaluate every host and build the custom
  packages on every push ([`check.yml`](.github/workflows/check.yml)).
- **AI-agent friendly**: [`AGENTS.md`](AGENTS.md) files next to the tricky code, plus Claude Code
  slash commands ([`.claude/commands/`](.claude/commands/)) for build, diff, rebuild, update and
  add-host.

## Hosts

| host | platform | what it is |
|---|---|---|
| `KOD-ADMINs-MacBook-Pro` ([`hosts/macbook`](hosts/macbook/)) | `aarch64-darwin` | Apple Silicon work Mac, the daily driver |
| `nixos` ([`hosts/nixos`](hosts/nixos/)) | `aarch64-linux` | headless [OrbStack](https://orbstack.dev) dev VM on that Mac |
| `nixos-desktop` ([`hosts/nixos-desktop`](hosts/nixos-desktop/)) | `x86_64-linux` | XFCE desktop VM under VirtualBox |

## How it works

`flake.nix` holds only the global identity and an explicit list of hosts. Builders in
[`lib/`](lib/) turn each host directory into a system by adding the platform layer
(`modules/darwin` or `modules/nixos`) and the shared home core. The Nix module system merges the
layers, so a shared module sets a `lib.mkDefault` and the host simply assigns over it.

```mermaid
flowchart LR
  F[flake.nix<br/>identity + host list] --> L[lib/<br/>mkDarwin · mkNixos]
  L --> P[modules/darwin · modules/nixos<br/>platform layer]
  L --> S[modules/home-shared<br/>shared home core]
  L --> H[hosts/&lt;name&gt;<br/>owns its config]
  H -. overrides .-> P
  H -. turns hn.* on .-> S
```

A feature is declared in one place, gated in its module, and enabled by the host that wants it:

```nix
# modules/home-shared/features.nix: declare (defaults lean off)
options.hn.atuin.enable = mkFeature "atuin" "Atuin shell history";

# modules/home-shared/programs/atuin.nix: gate
lib.mkIf config.hn.atuin.enable { programs.atuin.enable = true; }

# hosts/<name>/home.nix: opt in
hn.atuin.enable = true;
```

The full layer diagram is in [docs/architecture.md](docs/architecture.md).

## Structure

```
flake.nix        identity + explicit host list; packages, checks, devShells, apps, formatter
hosts/<name>/    one machine: default.nix (system) + home.nix (its hn.* toggles)
lib/             pure builders: mkDarwin / mkNixos + the shared home-manager block
modules/
  home-shared/   cross-platform home core: programs, packages, aliases, feature registry
  darwin/        macOS layer: nix settings, macOS defaults, Homebrew, macOS-only home modules
  nixos/         Linux layer: base config, XFCE desktop, OrbStack (generated)
pkgs/            custom packages, also built as flake checks
shells/          nix develop shells
secrets/         sops-nix scaffold
docs/            getting started, architecture, runbooks
```

## Quick start (macOS, Sep 2026)

nix-darwin can't install Nix or Homebrew itself, so a fresh Mac needs a one-time bootstrap.

1. Clone the repo to its canonical, user-owned path:

   ```bash
   sudo mkdir -p /etc/nix-darwin && sudo chown "$USER" /etc/nix-darwin
   git clone https://github.com/hahunavth/nix-config /etc/nix-darwin
   ```

2. Run the bootstrap. It installs the Xcode CLT, Homebrew and Nix (Determinate installer), then
   does the first switch:

   ```bash
   /etc/nix-darwin/scripts/bootstrap.sh
   ```

3. Approve the one-time GUI prompts (default browser, Accessibility) and set a Nerd Font in your
   terminal. After that, `rebuild` applies changes.

**Forking it?** Change `identity` in [`flake.nix`](flake.nix), copy `hosts/macbook/` to
`hosts/<you>/`, set your hostname there, and list it in `flake.nix`. `darwin-rebuild` picks the
config whose name matches the machine's hostname. See
[add-a-host](docs/runbooks/add-a-host.md) and, for Linux, [add-nixos-host](docs/runbooks/add-nixos-host.md).

## Everyday commands

| task | command | slash command |
|---|---|---|
| build without applying (no sudo) | `nix build .#darwinConfigurations.<host>.system` | `/build` |
| preview what would change | `nvd diff /run/current-system ./result` | `/diff` |
| apply | `rebuild` = `sudo darwin-rebuild switch --flake /etc/nix-darwin` | `/rebuild` |
| apply on any host by hostname | `nix run .#build-switch` | |
| roll back | `sudo darwin-rebuild switch --rollback` | |
| update inputs | `nix flake update`, then build every host | `/update` |
| format + lint | `nix fmt`, `nix flake check` | |
| collect garbage safely | `nh clean all --keep 5 --dry`, then without `--dry` | `/clean` |
| enter a dev shell | `nix develop .#<shell>` | |

NixOS VM: `orb -m nixos sudo nixos-rebuild switch --flake /private/etc/nix-darwin#nixos`.

## FAQ

**Why Homebrew for GUI apps instead of nixpkgs?** Casks install signed `.app` bundles into
`/Applications` where macOS expects them, and apps that update themselves keep working.
nix-darwin's `homebrew` module still keeps the set declarative (add a line to install it, delete
the line to uninstall), and nix-homebrew manages the Homebrew install itself.

**Why mise for language runtimes and not nix?** Projects pin their own versions in `.mise.toml`,
and switching versions shouldn't mean rebuilding the system. Nix provides the CLI tools; mise
provides Node, Java and pnpm.

**How do the Mac and the OrbStack VM share one checkout?** OrbStack mounts the Mac's filesystem
inside the VM, so `/etc/nix-darwin` on the Mac is `/private/etc/nix-darwin` in the VM. Edit once,
rebuild on each side. Because both load the same home core, the shell feels identical.

**I added a file and Nix says it doesn't exist.** Flakes only see git-tracked files. Run
`git add -A` before building. More in [troubleshooting](docs/troubleshooting.md).

## Documentation

| doc | covers |
|---|---|
| [Getting started](docs/getting-started.md) | fresh machine, manual steps, git identity |
| [Architecture](docs/architecture.md) | the layers, how a config is assembled, why this shape |
| [Where does X go?](docs/where-does-x-go.md) | which file to edit for an app, tool, alias or setting; the `hn.*` feature list |
| [Conventions & gotchas](docs/conventions.md) | rules of the repo, macOS quirks, dev toolchains |
| [Troubleshooting](docs/troubleshooting.md) | common errors and their fixes |
| [Runbooks](docs/README.md#runbooks) | rebuild & rollback, add a host, add a package, secrets |

## References

- [nix-darwin](https://github.com/nix-darwin/nix-darwin),
  [home-manager](https://github.com/nix-community/home-manager),
  [nix-homebrew](https://github.com/zhaofengli-wip/nix-homebrew),
  [sops-nix](https://github.com/Mic92/sops-nix),
  [treefmt-nix](https://github.com/numtide/treefmt-nix), [mise](https://mise.jdx.dev)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world) by ryan4yin
- Configs that shaped this one: [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config),
  [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config),
  [mitchellh/nixos-config](https://github.com/mitchellh/nixos-config),
  [Misterio77/nix-config](https://github.com/Misterio77/nix-config),
  [malob/nixpkgs](https://github.com/malob/nixpkgs)
