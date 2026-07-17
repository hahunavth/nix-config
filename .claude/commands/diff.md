---
description: Preview what a switch would change (nvd diff of current system vs fresh build)
allowed-tools: Bash(nix build:*), Bash(nvd diff:*), Bash(nix store diff-closures:*), Bash(git add:*), Bash(nix-store --query:*)
---
1. Build this machine's closure per /build so `./result` is fresh.
2. `nvd diff /run/current-system ./result`
   (fallback if nvd is unavailable: `nix store diff-closures /run/current-system ./result`)
3. Summarize: added/removed packages, version changes, closure size delta.
4. Homebrew casks do NOT appear in nvd output. If casks changed, diff the generated Brewfiles:
   `nix-store --query --requisites <path> | grep -- -Brewfile` for both `/run/current-system`
   and `./result`, then diff the two files.
5. Read-only: never switch from this command.
