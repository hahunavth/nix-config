# lib — AGENTS.md

Pure logic — the system builders. No validation registry (removed): hosts own
their config in `hosts/<name>/`, and the single user's identity is global in
`flake.nix`.

- **`mk-system.nix`** — `{ inputs, identity }` → `mkDarwin`/`mkNixos`, each taking a
  **host directory** (`./hosts/<name>`). Assembles: the platform base
  (`modules/darwin` | `modules/nixos`), the host's own `default.nix`, the home
  wiring, and (darwin) `nix-homebrew`. `identity` is threaded to every module as
  `userConfig` via `specialArgs`.
- **`mk-home.nix`** — the shared home-manager wiring: imports the platform home
  entry (`modules/*/home`) **plus** the host's `home.nix`, under
  `home-manager.users.${identity.username}`.

## How a host is built

`flake.nix` lists hosts explicitly, e.g.
`darwinConfigurations."KOD-ADMINs-MacBook-Pro" = mkDarwin ./hosts/work;`. The host's
`default.nix` sets its own `nixpkgs.hostPlatform` (so no `system` arg is passed) and
`networking.hostName`, and owns its machine-specific config. See
[`../hosts/AGENTS.md`](../hosts/AGENTS.md).

## Note

There is no hostname/profile/system validation anymore (the old `lib/hosts.nix`
registry was removed in favour of the reference "host owns everything" model). The
model assumes a single global user; a host needing a different username would need
per-host identity reintroduced.
