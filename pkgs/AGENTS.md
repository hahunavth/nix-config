# pkgs — AGENTS.md

Custom package derivations that aren't in (or are pinned outside) nixpkgs.

```
default.nix                       # aggregator -> flake `packages` + `checks`
atlassian-plugin-sdk/default.nix  # builder; both versions pinned in default.nix
claude-desktop/default.nix        # repack of Anthropic's official Linux .deb
opencode-desktop/default.nix      # repack of the upstream OpenCode .deb
```

The two `.deb` repacks are **x86_64-linux only** (for the `nixos-desktop` VM) and
are guarded behind a platform check in `default.nix`, so they never evaluate on
the Mac.

## Conventions

- Packages are **`fetchurl`-pinned** to an explicit URL + `sha256`. When bumping a
  version, update the URL, then update the hash — get the new hash from the build
  error's "got:" line, or `nix store prefetch-file <url>`.
- The SDK version pins live in [`./default.nix`](./default.nix), consumed by
  [`../modules/home-shared/programs/atlassian-sdk.nix`](../modules/home-shared/programs/atlassian-sdk.nix),
  which exposes them at stable `~/.local/share/...` paths.
- These are exported as flake `packages` and built by the `checks` output, so
  `nix flake check` (and CI) catches a rotted URL/hash instead of only at rebuild.
- Reference the current system as `pkgs.stdenv.hostPlatform.system` (not the
  deprecated `pkgs.system`).
