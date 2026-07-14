# hosts — AGENTS.md

**Each machine owns everything about itself here.** A host is a directory
`hosts/<name>/` with two modules, wired by `lib/mk-system.nix`:

- **`default.nix`** — the host's **system** module. Sets `nixpkgs.hostPlatform`,
  `networking.hostName`, and machine-specific system config; imports the reusable
  platform pieces it wants. Examples:
  - `macbook/` — a macOS host: its `homebrew.casks`, `networking.*`.
  - `nixos/` — imports `../../modules/nixos/orbstack/configuration.nix`.
  - `nixos-desktop/` — `imports = [ ./hardware-configuration.nix ../../modules/nixos/desktop ]`
    + boot + user + hostname.
- **`home.nix`** — the host's **home-manager** module: its `hn.*` feature toggles
  (e.g. `hn.atlassian.enable = true;`) and any host-only user packages/apps, layered
  on the shared core.

The reusable layers (`modules/{home-shared,darwin,nixos}`) and the platform base are
added by the builder — the host only declares its own extras + what it imports.

## Register a host

Add it to `flake.nix` (the attr name is the hostname, used by darwin-/nixos-rebuild):

```nix
darwinConfigurations."My-MBP" = mkDarwin ./hosts/mymbp;
# or
nixosConfigurations.myhost = mkNixos ./hosts/myhost;
```

Identity (username, emails, github) is **global** in `flake.nix` (`identity`),
threaded as `userConfig` — hosts don't set it. See
[`../docs/runbooks/add-a-host.md`](../docs/runbooks/add-a-host.md) and
[`add-nixos-host.md`](../docs/runbooks/add-nixos-host.md).
