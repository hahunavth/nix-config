# Troubleshooting

Each heading is the error or symptom you'll actually see, so you can search for it.

## `error: path '…/foo.nix' does not exist` right after creating the file

Flakes only see git-tracked files. Stage the new file and build again:

```bash
git add -A
nix build .#darwinConfigurations.KOD-ADMINs-MacBook-Pro.system
```

## Nix asks for `--impure`, or `flake.lock` is root-owned

`flake.lock` must be git-tracked and owned by your user. Don't pass `--impure`. If a root shell
rewrote the lock file, run `sudo chown "$USER" flake.lock` and run `darwin-rebuild` as yourself
(it calls sudo where it needs to).

## An app I installed disappeared after `rebuild`

`homebrew.onActivation.cleanup = "zap"` removes any cask that nix doesn't declare. Add the app
to `modules/darwin/homebrew/casks/*.nix` (every Mac) or to `homebrew.casks` in
`hosts/<name>/default.nix` (one Mac). See [add-a-package](runbooks/add-a-package.md).

## A `system.defaults` change didn't take effect

Dock, Finder, WindowManager and input-source settings are only reread at login. Log out, or
restart the process (`killall Dock`, `killall Finder`).

## Prompt shows boxes instead of icons

The terminal font isn't a Nerd Font. Set it to JetBrainsMono or FiraCode Nerd Font; iTerm2
renders them best.

## The top-left key types `§`/`±` instead of `` ` ``/`~`

macOS guessed the wrong keyboard type. Re-run the Keyboard Setup Assistant (System Settings →
Keyboard). Don't remap keys with `hidutil`.

## Vietnamese or Japanese input disappeared after a switch

Something declared `AppleEnabledInputSources`, which replaces the whole list. Remove that
declaration and re-add the input sources by hand. See [conventions](conventions.md#macos-specifics).

## `mise WARN missing: …`

The project pins tool versions that aren't installed yet. Run `mise install` in that repo.

## `atlas-version: command not found`

The SDK is only on PATH inside an `atlas-mise-enable`d plugin repo, and it needs a JDK activated
by mise. Run `atlas-mise-enable` once in the repo and check out the branch again.

## `atlas-mvn` tries to write into the read-only SDK directory

Point Maven at your own repository:
`export MAVEN_OPTS=-Dmaven.repo.local=$HOME/.m2/repository`.

## Something broke after a switch

Roll back to the previous generation. See [rebuild-and-rollback](runbooks/rebuild-and-rollback.md#rollback).
