# Ad-hoc Python shell: `nix develop .#python`.
# For data-science work use the miniconda cask (see AGENTS.md "Dev toolchains");
# this is a lightweight uv-based entry for general scripting.
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    python3
    uv
  ];
}
