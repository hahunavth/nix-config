# treefmt config powering `nix fmt`. nixfmt is the only formatter wired up, so
# the excludes below are two different things: the generated/vendored TREES
# (which must stay byte-identical for re-sync diffs) and every non-Nix file
# extension (nothing would format them — listing them just keeps the traversal
# quiet). Adding a formatter for one of those types means removing its line.
{
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  settings.global.excludes = [
    "modules/nixos/orbstack/*" # OrbStack-generated; keep verbatim for re-sync diffs
    "tmp/*" # vendored reference repos
    "flake.lock"
    "*.md"
    "*.sh"
    "*.mp3"
    "*.lua"
    "*.toml"
    "*.json"
    "*.yaml"
    ".envrc"
    "*.pem"
  ];
}
