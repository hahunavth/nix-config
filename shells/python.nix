# Ad-hoc Python shell: `nix develop .#python`.
#
# Python is the one runtime mise does NOT own here — conda does, via the
# miniconda cask (modules/darwin/home/conda.nix). Use conda for anything
# data-science; this uv-based shell is for general scripting, and unlike a
# conda env it is pinned by the flake lock.
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    python3
    uv
  ];
}
