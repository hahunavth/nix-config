{ ... }:

{
  # Build Linux/NixOS artifacts from the Mac via a managed lightweight Linux VM
  # (aarch64-linux by default). Heavy: runs a background VM; first switch fetches
  # and starts the builder image. To disable on a host, set
  # `nix.linux-builder.enable = false;` in its hosts/<name>/default.nix.
  nix.linux-builder = {
    enable = true;
    maxJobs = 4;
  };

  # (trusted-users for build offloading is set in darwin/nix-settings.nix)
}
