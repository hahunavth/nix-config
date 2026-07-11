# pkgs — AGENTS.md

Custom package derivations that aren't in (or are pinned outside) nixpkgs.

```
raycast-beta/default.nix          # Raycast Beta, fetchurl-pinned
atlassian-plugin-sdk/default.nix  # both SDK versions, fetchurl-pinned
```

## Conventions

- Packages are **`fetchurl`-pinned** to an explicit URL + `sha256`. When bumping a
  version, update the URL, then update the hash — get the new hash from the build
  error's "got:" line, or `nix store prefetch-file <url>`.
- The SDK version pins live in [`./default.nix`](./default.nix), consumed by
  [`../modules/shared/programs/atlassian-sdk.nix`](../modules/shared/programs/atlassian-sdk.nix),
  which exposes them at stable `~/.local/share/...` paths.
- These are exported as flake `packages` and built by the `checks` output, so
  `nix flake check` (and CI) catches a rotted URL/hash instead of only at rebuild.
- Reference the current system as `pkgs.stdenv.hostPlatform.system` (not the
  deprecated `pkgs.system`).
