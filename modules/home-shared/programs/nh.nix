{ pkgs, ... }:

{
  # nh wraps darwin-rebuild/nixos-rebuild with a live build tree and a package
  # diff of what the new generation changes — the diff is the reason to use it,
  # since a plain switch reports success without saying what moved.
  #
  # `flake` exports NH_FLAKE, so `nh darwin switch` needs no --flake from any
  # directory. The two paths are one checkout: the OrbStack VM sees the Mac's
  # /etc/nix-darwin at /private/etc/nix-darwin over virtiofs.
  programs.nh = {
    enable = true;
    flake = if pkgs.stdenv.isDarwin then "/etc/nix-darwin" else "/private/etc/nix-darwin";
    # Do NOT enable programs.nh.clean. Garbage collection is already scheduled
    # by nix.gc (modules/darwin/nix-settings.nix, modules/nixos/configuration.nix);
    # a second timer with its own retention policy would fight the first, and
    # whichever is stricter silently wins.
  };

  # nvd on its own too, for diffing two closures without switching — what
  # /diff uses to preview a rebuild.
  home.packages = [ pkgs.nvd ];
}
