# Layer 3 of 4 — the Linux home layer, mirroring modules/darwin/home.
#
# Currently a pass-through: everything the Linux hosts need from home-manager is
# already cross-platform, so there is nothing Linux-only to add. Kept as a file
# rather than collapsed, so lib/mk-system.nix has a symmetrical entry point per
# platform and a future Linux-only module has an obvious home.
{ ... }:

{
  imports = [
    ../../home-shared # cross-platform home (modules/home-shared)
  ];
}
