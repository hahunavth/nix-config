{ pkgs, ... }:

{
  # nh: nicer `nh darwin switch` (live build tree + a diff of what each rebuild
  # changes). flake= sets NH_FLAKE so it needs no --flake.
  programs.nh = {
    enable = true;
    flake = "/etc/nix-darwin";
    # Do NOT enable programs.nh.clean — nix.gc (modules/darwin/core.nix) already
    # handles garbage collection; enabling both would double up.
  };

  # standalone closure-diff tool (nix store diff-closures front-end)
  home.packages = [ pkgs.nvd ];
}
