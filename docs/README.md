# Docs

Guides for setting up and living with this config. For the overview, see the
[top-level README](../README.md). For AI agents, see [`AGENTS.md`](../AGENTS.md).

## Guides

| doc | covers |
|---|---|
| [getting-started.md](getting-started.md) | fresh machine, manual steps nix can't do, git identity |
| [architecture.md](architecture.md) | the layers, system vs home scope, flake outputs, why this shape |
| [where-does-x-go.md](where-does-x-go.md) | which file to edit for an app, tool, alias or setting; the `hn.*` feature registry |
| [conventions.md](conventions.md) | repo rules, macOS quirks, dev toolchains |
| [troubleshooting.md](troubleshooting.md) | common errors, each headed by the message you'll see |

## Runbooks

| runbook | when |
|---|---|
| [rebuild-and-rollback.md](runbooks/rebuild-and-rollback.md) | applying changes and backing them out |
| [add-a-host.md](runbooks/add-a-host.md) | adding a machine (macOS) |
| [add-nixos-host.md](runbooks/add-nixos-host.md) | adding a Linux host or VM |
| [add-a-package.md](runbooks/add-a-package.md) | a GUI app, CLI tool, runtime or custom package |
| [secrets.md](runbooks/secrets.md) | setting up sops-nix and handling keys |

## Elsewhere in the repo

- [`shells/README.md`](../shells/README.md): the `nix develop` shells
- [`secrets/README.md`](../secrets/README.md): the sops-nix scaffold
- Nested `AGENTS.md` files in `hosts/`, `lib/`, `pkgs/`, `modules/home-shared/programs/`,
  `modules/darwin/homebrew/` and `modules/nixos/orbstack/`

## History

- [history/refactor-plan.md](history/refactor-plan.md): the plan this layout came from
  (archived; its paths describe the old layout)
