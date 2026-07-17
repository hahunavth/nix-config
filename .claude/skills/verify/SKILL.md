---
name: verify
description: Verify a nix-darwin/home-manager change actually landed by building the closure and inspecting the concrete generated artifacts (home-files, Brewfile, activation scripts) — without switching.
---
# Verify a config change (no switch needed)

1. `git add -A`, then build this machine's closure per /build so `./result` is fresh.
2. Map each change in the working diff (`git diff HEAD --name-only`) to a concrete artifact:

| What changed | Evidence to inspect |
| --- | --- |
| home-manager dotfile/program (modules/home-shared/**, hosts/*/home.nix) | `HMG=$(nix-store --query --requisites ./result \| grep -m1 home-manager-generation)`; inspect the exact generated file under `$HMG/home-files/`, e.g. `$HMG/home-files/.zshrc`, `$HMG/home-files/.config/git/config` |
| CLI package added/removed | `ls "$HMG/home-path/bin/" \| grep <tool>` |
| Homebrew cask | `BF=$(nix-store --query --requisites ./result \| grep -m1 -- -Brewfile)`; grep the cask name in `$BF` |
| Shell alias (modules/home-shared/aliases/) | grep the alias in `$HMG/home-files/.zshrc` |
| darwin system setting (system.defaults, ...) | grep `./result/activate` and `./result/etc/`, or `nix eval .#darwinConfigurations."$HOST".config.<option path>` |
| NixOS host change | eval is sufficient: `nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`, or `nix eval` the specific option |

3. Quote the matching lines as proof. If the change is absent from the built artifact, the
   module is not wired in — check imports and `hn.*` feature toggles before suspecting
   anything else.
4. Never switch as part of verification. `home-files` entries may be store symlinks; `cat`
   follows them.
