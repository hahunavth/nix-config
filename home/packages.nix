{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    nil           # Nix language server (LSP)
    nixfmt        # Nix formatter
    socat
    # CLI to create SSH tunnels / port forwarding
    # (marked broken in nixpkgs 26.05, but verified to build fine here, so clear the flag)
    (mole.overrideAttrs (old: { meta = old.meta // { broken = false; }; }))
    # Apple Silicon resource monitor
    # (skip the integration tests: they need real-hardware sysctl etc. and fail in the build sandbox)
    (mactop.overrideAttrs (_: { doCheck = false; }))
    macpm         # Apple Silicon power/GPU monitor (successor to asitop, needs sudo)
    ranger
  ];
}
