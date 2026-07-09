{ ... }:

{
  # Build Linux/NixOS artifacts from the Mac via a managed lightweight Linux VM
  # (aarch64-linux by default). Heavy: runs a background VM; first switch fetches
  # and starts the builder image. Remove this module to disable.
  nix.linux-builder = {
    enable = true;
    maxJobs = 4;
  };

  # The nix-daemon must trust the admin user to offload builds to the builder.
  # (root is always trusted implicitly; this merges with the default list.)
  nix.settings.trusted-users = [ "kod_admin" ];
}
