# modules/darwin/homebrew/profiles — AGENTS.md

Per-profile Homebrew overrides. A host picks a profile in `hosts/<name>.nix`
(`profile = "work" | "personal"`); [`../default.nix`](../default.nix) composes
`common` + the chosen profile.

```
common.nix    # shared base: taps / brews / casks / masApps for every profile
lib.nix       # mkProfile helper (defines the extra*/remove* schema)
work.nix      # work overrides
personal.nix  # personal overrides
```

## mkProfile semantics

A profile describes **only the delta** from `common.nix`:

- `extraTaps` / `extraBrews` / `extraCasks` — **add** to the shared lists.
- `removeTaps` / `removeBrews` / `removeCasks` — **subtract** from the shared lists.
- `masApps` — merged over `common.masApps`.

Composition (in `../default.nix`): `final = (common ++ extra) - remove`. So to give
one machine an app, add it to that profile's `extraCasks`; to hide a shared app
from one machine, add it to that profile's `removeCasks`. Never duplicate a shared
package into a profile.
