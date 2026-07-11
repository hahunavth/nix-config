# lib — AGENTS.md

Pure logic — no system config. Three files:

- **`hosts.nix`** — the host-registry loader. Reads [`../hosts/`](../hosts), validates
  every entry, enriches it with defaults, returns `validatedConfigsChecked` (the
  `userConfig` list the flake partitions into darwin/nixos configurations).
- **`mk-system.nix`** — `mkDarwin`/`mkNixos` builders: assemble the `modules/`
  layers (system + `…/home/` + shared) into a configuration. Keeps flake.nix thin.
- **`mk-home.nix`** — the shared home-manager wiring used by both builders.

## Validation contract (what a host entry must satisfy)

- **Required attrs**: `username`, `hostname`, `fullName`, `githubUsername`
  (`fullName`/`githubUsername` usually come from `hosts/common.nix`).
- **`hostname`** must match `[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*` and be **unique** across
  all hosts (duplicates throw).
- **`email`**, if set, must look like an email.
- **`profile`** ∈ `{ personal, work }`.
- **`system`** ∈ `{ aarch64-darwin, x86_64-darwin, aarch64-linux, x86_64-linux }`;
  defaults to `aarch64-darwin`. A `*-linux` system routes the host to
  `nixosConfigurations` instead of `darwinConfigurations`.
- Optional with defaults: `workEmail`, `signingKey` (both default `""`), `profile`
  (`personal`), `system` (`aarch64-darwin`).

## When editing

- Adding a new **field** to host entries means: give it a default in
  `mkEnhancedConfig`, and (if it has a constrained value set) a check in
  `validateConfig`. The `features` set introduced in Phase 1 is validated here.
- Keep error messages actionable — they're the first thing a new-host author sees.
