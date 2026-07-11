Build this machine's system closure without applying it (no sudo). Use this to
verify a change before switching.

Steps:
1. `git add -A` (flakes ignore untracked files).
2. macOS: `nix build .#darwinConfigurations.$(scutil --get LocalHostName || hostname -s).system`
   — if that name doesn't match, list them with
   `nix eval .#darwinConfigurations --apply builtins.attrNames`.
   Linux VM: `nix build .#nixosConfigurations.nixos.config.system.build.toplevel`.
3. Report the result. On failure, show the error and propose a fix — do not switch.

Prefer the `nixos` MCP server for any package/option lookups.
