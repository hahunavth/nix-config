# modules/darwin/homebrew — AGENTS.md

Homebrew layer. `default.nix` wires nix-homebrew and sets the **shared base**
package lists (apply to every macOS host); the data lives beside it.

```
default.nix           # nix-homebrew wiring + the shared base lists
taps.nix              # Homebrew taps (base)
brews/core.nix        # CLI formulae via brew (base)
casks/apps.nix        # GUI apps (base)
casks/development.nix # dev GUI apps (base)
casks/system.nix      # menu-bar / system utilities (base)
```

## Rules

- **`onActivation.cleanup = "zap"`** — anything installed via Homebrew but **not**
  listed here (nor in a host module) is **removed** on the next rebuild.
- **Base vs. host-specific**: lists here apply to *all* macOS hosts. Casks unique
  to one machine are **owned by that host** — add `homebrew.casks = [ … ];` in
  `hosts/<name>/default.nix`; `homebrew.casks` is a list option
  so it merges with the base here. (This replaced the old work/personal profile
  overrides — a host now owns its own extras.)
- **GUI apps → casks; CLI tools → prefer nix** (`modules/home-shared/packages/`).
  Only use a `brew` when the tool isn't viable via nixpkgs.
