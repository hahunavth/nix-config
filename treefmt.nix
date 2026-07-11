# treefmt config powering `nix fmt`. Formats Nix with nixfmt-rfc-style, and
# excludes generated/vendored trees so `nix fmt` never rewrites them.
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
