---
description: Add a GUI app (Homebrew cask), CLI tool (nix), or runtime (mise)
argument-hint: "<package-name>"
---
Add a GUI app (Homebrew cask) or CLI tool. Follow docs/runbooks/add-a-package.md:

- **GUI app** → add the cask to `modules/darwin/homebrew/casks/{apps,development,system}.nix`
  (all hosts) or `homebrew.casks` in `hosts/<name>/default.nix` (one host).
  Remember `onActivation.cleanup = "zap"`: unlisted casks get uninstalled.
- **CLI tool** → prefer nix: add to `modules/home-shared/packages/{development,system}.nix`.
  Confirm the attribute/name via the `nixos` MCP server first.
- **Language runtime** → not a package; use mise (see AGENTS.md).

Then verify with /build (the git-add hook stages new files).
