Add a new machine. Each host OWNS its config under hosts/<name>/. Follow
docs/runbooks/add-a-host.md (or add-nixos-host.md for NixOS):

1. Create `hosts/<name>/default.nix` (system: `nixpkgs.hostPlatform`,
   `networking.hostName`, its casks/hardware/imports) and `hosts/<name>/home.nix`
   (home: `hn.*` feature toggles + host-only user config).
2. List it in `flake.nix` — the attr name is the hostname:
   `darwinConfigurations."<hostname>" = mkDarwin ./hosts/<name>;` (or `mkNixos`).
3. `git add -A`, then verify it evaluates + builds (see /build).

Identity (username, emails) is global in `flake.nix` (`identity`) — hosts don't set
it. There's no validation registry; the host's `default.nix` sets its own platform.
