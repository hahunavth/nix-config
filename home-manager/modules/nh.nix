{ pkgs, ... }:

{
  # nh: nicer `nh darwin switch` / `nh os switch` (live build tree + a diff of
  # what each rebuild changes). flake= sets NH_FLAKE so it needs no --flake.
  # On the OrbStack VM the repo is reached via the Mac mount (/private/etc/...).
  programs.nh = {
    enable = true;
    flake = if pkgs.stdenv.isDarwin then "/etc/nix-darwin" else "/private/etc/nix-darwin";
    # Do NOT enable programs.nh.clean — nix.gc already handles garbage
    # collection (darwin/nix-settings.nix / nixos/configuration.nix); enabling
    # both would double up.
  };

  # standalone closure-diff tool (nix store diff-closures front-end)
  home.packages = [ pkgs.nvd ];
}
