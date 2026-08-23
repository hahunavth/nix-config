# direnv — per-directory environments from a project's .envrc. nix-direnv makes
# `use flake` cheap by caching the dev shell and keeping it GC-rooted, so
# entering a project does not re-evaluate it every time. This repo's own .envrc
# uses it to drop you into shells/default.nix.
{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
