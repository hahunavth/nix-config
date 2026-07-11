# Ad-hoc Node shell: `nix develop .#node`.
# For pinned per-project versions prefer mise (Node LTS + pnpm are global
# defaults); use this for a quick reproducible entry without a .mise.toml.
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    nodejs_22
    pnpm
  ];
}
