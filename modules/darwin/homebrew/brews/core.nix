# Homebrew FORMULAE (CLI, not GUI) for every macOS host. Empty, and that is the
# expected state.
#
# CLI tools belong in nix — modules/home-shared/packages/ — where they are
# pinned by the flake lock and identical on the Linux hosts. This list is the
# escape hatch for the case where the nixpkgs build is missing or broken on
# darwin, so a new entry deserves a comment saying which.
[ ]
