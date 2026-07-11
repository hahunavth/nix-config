Build AND apply this machine's configuration.

1. First build only (see /build) and confirm it's green.
2. Then apply:
   - macOS: `sudo darwin-rebuild switch --flake /etc/nix-darwin`
   - Linux VM (run inside it): `orb -m nixos sudo nixos-rebuild switch --flake /private/etc/nix-darwin#nixos`
3. Run `darwin-rebuild` as the user, never via a root shell (keeps flake.lock user-owned).

Confirm with the user before switching if the diff touches system-level modules.
