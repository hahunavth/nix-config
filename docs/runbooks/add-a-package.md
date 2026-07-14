# Runbook: add a package

Decide *what kind* of thing it is first (see the decision diagram in the README).

## GUI app (macOS)

Add the cask to the right list under `modules/darwin/homebrew/casks/`:

- shared across all profiles → `apps.nix` / `development.nix` / `system.nix`
- one machine only → `homebrew.casks` in `hosts/<name>/default.nix`

`onActivation.cleanup = "zap"` uninstalls anything not listed, so adding the line
*is* the install and removing it *is* the uninstall.

## CLI tool

Add to `modules/home-shared/packages/development.nix` or `system.nix`. Prefer nix
over a Homebrew `brew` unless the tool isn't viable in nixpkgs.

Check availability / options with the `nixos` MCP server rather than guessing an
attribute name.

## Language runtime (node, java, python, …)

Not a package — use **mise**. Global default: `programs.mise.globalConfig` in
`modules/home-shared/programs/mise.nix`. Per-project: a `.mise.toml` in that repo. Run
`mise install` after editing.

## Custom / pinned package

Add a derivation under `pkgs/` (see [`../../pkgs/AGENTS.md`](../../pkgs/AGENTS.md)) and
reference it from the module that needs it.

## Then

```bash
git add -A
nix build .#darwinConfigurations.<host>.system
```
