---
description: Update flake inputs, verify all hosts build/eval, summarize bumps — never switch
argument-hint: "[input-name]"
allowed-tools: Bash(nix flake update:*), Bash(nix build:*), Bash(nix eval:*), Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(nvd diff:*)
---
1. Check `git status` first; warn if flake.lock already has uncommitted changes.
2. Update: `nix flake update` (all inputs), or `nix flake update $ARGUMENTS` for one input.
3. Summarize the lock change from `git diff flake.lock`: per input, old -> new rev and
   lastModified date.
4. Verify every host:
   - Darwin (full build): `nix build .#darwinConfigurations."$HOST".system` (HOST per /build)
   - NixOS (eval only; cross-building aarch64/x86_64-linux locally is not expected):
     `nix eval --raw .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath`
     `nix eval --raw .#nixosConfigurations.nixos-desktop.config.system.build.toplevel.drvPath`
5. Show version bumps a switch would bring: `nvd diff /run/current-system ./result`.
6. Report inputs bumped + notable package version changes + build status. Do NOT switch —
   tell the user to run /rebuild when ready.

On failure: show the error and offer `git checkout -- flake.lock` to revert the update.
