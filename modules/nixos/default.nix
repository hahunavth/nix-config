# Layer 1 of 4 — the Linux platform base, system scope. The counterpart of
# modules/darwin, applied to every NixOS host by lib/mk-system.nix.
#
# Thin by design, because the two Linux hosts have almost nothing in common
# beyond nix itself: one is a headless OrbStack container, the other a GUI VM.
# Hardware, boot, desktop and guest integration are all per-host, in
# hosts/<name>/default.nix, which the builder merges alongside this.
{
  imports = [
    ./configuration.nix
  ];
}
