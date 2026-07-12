Add a GUI app (Homebrew cask) or CLI tool. Follow docs/runbooks/add-a-package.md:

- **GUI app** → add the cask to `modules/darwin/homebrew/casks/{apps,development,system}.nix`
  (all hosts) or `homebrew.casks` in `hosts/<name>/default.nix` (one host).
  Remember `onActivation.cleanup = "zap"`: unlisted casks get uninstalled.
- **CLI tool** → prefer nix: add to `modules/shared/packages/{development,system}.nix`.
  Confirm the attribute/name via the `nixos` MCP server first.
- **Language runtime** → not a package; use mise (see AGENTS.md).

Then `git add -A` and verify with /build.
