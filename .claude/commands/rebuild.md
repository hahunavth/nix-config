---
description: Build AND apply this machine's configuration (requires sudo)
---
1. Build first (see /build) and confirm it is green. For nontrivial changes, run /diff and
   confirm with the user before switching, especially if system-level modules changed.
2. Apply:
   - macOS: `sudo darwin-rebuild switch --flake .` (from the repo root; this is what the
     `rebuild` zsh alias does).
   - NixOS VM (runs inside it): `orb -m nixos sudo nixos-rebuild switch --flake /private/etc/nix-darwin#nixos`
3. Run `darwin-rebuild` under the user with sudo, never from a root shell (keeps flake.lock
   user-owned).
4. Afterwards, suggest /verify for the specific change if it has an inspectable artifact.
