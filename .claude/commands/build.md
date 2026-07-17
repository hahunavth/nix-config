---
description: Build this machine's system closure without applying it (no sudo)
argument-hint: "[host]"
allowed-tools: Bash(nix build:*), Bash(nix eval:*), Bash(git add:*), Bash(scutil --get LocalHostName), Bash(hostname -s)
---
Build the system closure to verify a change before switching. Never pass `--impure`.

1. `git add -A` (flakes ignore untracked files; a PreToolUse hook also does this).
2. Pick the target (host = `$ARGUMENTS`; default: this machine):
   - This Mac: `HOST="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"`, then
     `nix build .#darwinConfigurations."$HOST".system`
   - A NixOS host: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
     (eval-only from the Mac: append `--dry-run`, or eval the `.drvPath`).
   - If the attr doesn't exist, list hosts:
     `nix eval .#darwinConfigurations --apply builtins.attrNames` (same for `nixosConfigurations`).
3. Report the result. On failure, show the error and propose a fix — do not switch.

Prefer the `nixos` MCP server for any package/option lookups.
