# System / networking / monitoring CLI tools.
#
# socat is load-bearing rather than incidental: the hl-* homelab port forwards
# (../aliases/homelab-tunnel.nix) are socat invocations.
{ pkgs, lib, ... }:

{
  home.packages =
    (with pkgs; [
      socat
      ranger
    ])
    # Apple Silicon power/thermal monitors. Not merely unused on Linux — they
    # do not build there, so this has to be a platform conditional rather
    # than a shared list.
    ++ lib.optionals pkgs.stdenv.isDarwin [
      # Resource monitor. Tests disabled because they read real-hardware
      # sysctls, which the build sandbox does not expose — the failure is the
      # sandbox, not the package.
      (pkgs.mactop.overrideAttrs (_: {
        doCheck = false;
      }))
      pkgs.macpm # Apple Silicon power/GPU monitor (successor to asitop, needs sudo)
    ];
}
