# A managed Linux VM that acts as a nix remote builder, so the Mac can build
# aarch64-linux derivations without one.
#
# On by default because the alternative is that every Linux-targeting build
# simply fails on the wrong platform. It is not free, though: a background VM
# runs, and the first switch has to fetch and start the builder image.
#
# hosts/macbook disables it — evaluating the NixOS hosts from the Mac only needs
# `--dry-run`, and their real switches happen inside the VMs themselves.
#
# mkDefault is what makes that host-level `enable = false;` win without needing
# mkForce.
{ lib, ... }:

{
  nix.linux-builder = {
    enable = lib.mkDefault true;
    maxJobs = 4;
  };

  # Offloading also requires the user to be in nix.settings.trusted-users, which
  # ./nix-settings.nix sets. Without it the daemon ignores the builder silently.
}
