# Template for hosts/default.nix — copy and fill in your machines:
#   mkdir -p hosts && cp hosts.example.nix hosts/default.nix
{
  common = {
    fullName = "Your Name";
    githubUsername = "your-github";
    email = "you@example.com";
    workEmail = ""; # optional; used for work-directory git identity
    signingKey = ""; # optional; git commit signing key
  };

  hosts = {
    work = {
      username = "youruser";
      hostname = "Your-Work-MBP";
      profile = "work";
      # system is optional; defaults to "aarch64-darwin" (Apple Silicon).
      # Allowed: aarch64-darwin, x86_64-darwin, aarch64-linux, x86_64-linux.
      # A *-linux system builds a nixosConfigurations entry instead of darwin.
      system = "aarch64-darwin";
      # Optional per-host feature toggles (see home-manager/modules/features.nix).
      # Unset keys fall back to per-profile defaults; "work" enables atlassian +
      # winTunnel, macOS enables hammerspoon + defaultBrowser. Override like:
      #   features = { hammerspoon = false; };
    };

    personal = {
      username = "you";
      hostname = "Your-Personal-MBP";
      profile = "personal";
      system = "aarch64-darwin";
      # A personal Mac drops all KOD/work tooling by default (atlassian +
      # winTunnel off via the "personal" profile). Opt back in per-feature:
      #   features = { atlassian = true; };
    };

    # Example headless Linux (e.g. an OrbStack NixOS VM):
    # dev = {
    #   username = "you";
    #   hostname = "nixos";
    #   profile = "personal"; # unused on Linux, but must be valid
    #   system = "aarch64-linux";
    # };
  };
}
