# Core system aliases.
{
  # Rebuild the system from the flake (works from any directory)
  rebuild = "sudo darwin-rebuild switch --flake /etc/nix-darwin";
  # Same, via nh: unprivileged build + a diff of what changed (uses NH_FLAKE)
  rebuild2 = "nh darwin switch";
}
