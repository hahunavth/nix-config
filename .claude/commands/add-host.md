Add a new machine to the registry. Follow docs/runbooks/add-a-host.md:

1. Create `hosts/<name>.nix` with `username`, `hostname` (unique, [a-zA-Z0-9-]),
   `profile` (personal|work), optional `system` (default aarch64-darwin) and
   optional `features = { … }` (see modules/shared/features.nix).
2. Register it in `hosts/default.nix`.
3. `git add -A`, then verify it evaluates + builds (see /build).

`lib/hosts.nix` validates the entry; a `*-linux` system routes it to
nixosConfigurations instead of darwinConfigurations.
