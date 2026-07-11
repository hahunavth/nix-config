# modules/darwin/homebrew — AGENTS.md

Self-contained Homebrew layer. `default.nix` wires nix-homebrew and composes the
package lists (base + profile overrides); `lib.nix` holds the composeList helpers.
The **data** — flat lists of taps / brews / casks — sits beside them. Edit the
lists; keep conditionals/composition in `default.nix`.

```
default.nix           # nix-homebrew wiring + list composition (the logic)
lib.nix               # composeList/unique/removeItems helpers
taps.nix              # Homebrew taps (shared)
brews/core.nix        # CLI formulae installed via brew (shared)
casks/apps.nix        # GUI apps (shared)
casks/development.nix # dev GUI apps (shared)
casks/system.nix      # menu-bar / system utilities (shared)
profiles/             # common.nix + work/personal overrides (see profiles/AGENTS.md)
```

## Rules

- **`onActivation.cleanup = "zap"`** — anything installed via Homebrew but **not**
  listed here (or in a profile) is **removed** on the next rebuild. Adding a cask
  here is how you keep it; deleting a line uninstalls it.
- **Shared vs. profile**: lists here apply to *all* profiles. For one-profile-only
  packages, use `extraCasks`/`removeCasks` in
  [`./profiles/<profile>.nix`](./profiles) instead — see
  [`./profiles/AGENTS.md`](./profiles/AGENTS.md).
- **GUI apps → casks; CLI tools → prefer nix** (`modules/shared/packages/`).
  Only use a `brew` when the tool isn't viable via nixpkgs.
- The Atlassian Plugin SDK is intentionally **not** here (nix-pinned instead).
