# Ad-hoc Node shell: `nix develop .#node`.
#
# mise owns per-project Node versions (LTS + pnpm are its globals) and is what
# a real project should use. Reach for this instead when you want a version
# pinned by the flake lock rather than resolved at `mise install` time, or when
# the directory should not gain a .mise.toml at all.
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    nodejs_22
    pnpm
  ];
}
