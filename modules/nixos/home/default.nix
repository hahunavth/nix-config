# Linux home-manager entry: the shared cross-platform layer (+ future
# Linux-only modules). Wired as the nixos home entry point by lib/mk-system.nix.
{ ... }:

{
  imports = [
    ../../shared # cross-platform home (modules/shared)
  ];
}
