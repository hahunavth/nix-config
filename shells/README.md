# shells/

Project dev shells, entered with `nix develop .#<name>` (or `nix develop` for
`default`). Each file is `{ pkgs }: pkgs.mkShell { … }`, wired into the flake's
`devShells` via an `importShell` helper.

| shell | for |
|---|---|
| `default` | editing this config repo (nixfmt, statix, deadnix, nil) |
| `atlassian` | quick Maven/JDK17 entry for plugin work |
| `node` | Node 22 + pnpm |
| `python` | Python 3 + uv |

**Relationship to mise:** mise pins *per-project* runtime versions (`.mise.toml`,
resolved at `mise install` time). These shells give a *reproducible ad-hoc entry*
without editing a project's `.mise.toml`. Prefer mise inside real project repos;
reach for a devshell for one-off or throwaway work.

Add one: drop `shells/<name>.nix` here and add `<name> = importShell "<name>";`
to `devShells` in `flake.nix`.
