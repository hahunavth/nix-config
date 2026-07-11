# System / networking / monitoring CLI tools.
{ pkgs, lib, ... }:

{
  home.packages =
    (with pkgs; [
      socat
      ranger
      # CLI to create SSH tunnels / port forwarding
      # (marked broken in nixpkgs 26.05, but verified to build fine here, so clear the flag)
      (mole.overrideAttrs (old: {
        meta = old.meta // {
          broken = false;
        };
      }))
    ])
    # Apple Silicon-only monitors — don't exist on Linux.
    ++ lib.optionals pkgs.stdenv.isDarwin [
      # Resource monitor. Skip the integration tests: they need real-hardware
      # sysctl etc. and fail in the build sandbox.
      (pkgs.mactop.overrideAttrs (_: {
        doCheck = false;
      }))
      pkgs.macpm # Apple Silicon power/GPU monitor (successor to asitop, needs sudo)
    ];
}
