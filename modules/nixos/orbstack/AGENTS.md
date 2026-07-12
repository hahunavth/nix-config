# modules/nixos/orbstack — AGENTS.md

**GENERATED, not hand-written. Do not edit these files.**

`configuration.nix`, `orbstack.nix`, and `incus.nix` here are copied **verbatim**
from the OrbStack NixOS VM's `/etc/nixos`. OrbStack owns them: it regenerates them
on the VM, and they carry guest integration (virtiofs mounts, the `kod_admin`
user, hostname, timezone, `system.stateVersion = "25.11"`, and the
`orbstack`-provided SSH).

## Rules

- **Never hand-edit** files in this directory. If the VM regenerates
  `/etc/nixos/*`, re-copy them here and `git diff` to review the change.
- **sshd stays disabled** (`orbstack.nix`) — OrbStack provides SSH itself
  (`orb -m nixos`, `ssh nixos@orb`). Do **not** add `services.openssh.enable`.
- This guest config is wired into the `nixos` host by
  [`../hosts/nixos/default.nix`](../hosts/nixos/default.nix). The shared,
  hand-maintained NixOS base is [`../configuration.nix`](../configuration.nix) —
  put cross-host changes there, `nixos`-only changes in `../hosts/nixos/`.
- Login shell is set via `users.defaultUserShell` (the user has
  `useDefaultShell`); don't set it per-user here.

## Apply (run inside the VM)

```bash
orb -m nixos sudo nixos-rebuild switch --flake /private/etc/nix-darwin#nixos
```
