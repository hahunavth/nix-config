{ lib, userConfig, ... }:

# Darwin-level feature gate. The home-manager `hn.*` options live in a separate
# module system, so darwin modules read the per-host `features` set directly.
lib.mkIf (userConfig.features.linuxBuilder or true) {
  # Build Linux/NixOS artifacts from the Mac via a managed lightweight Linux VM
  # (aarch64-linux by default). Heavy: runs a background VM; first switch fetches
  # and starts the builder image. Set `features.linuxBuilder = false` to disable.
  nix.linux-builder = {
    enable = true;
    maxJobs = 4;
  };

  # (trusted-users for build offloading is set in darwin/nix-settings.nix)
}
