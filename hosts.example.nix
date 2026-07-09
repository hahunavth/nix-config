# Template for hosts.nix — copy and fill in your machines:
#   cp hosts.example.nix hosts.nix
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
    };

    personal = {
      username = "you";
      hostname = "Your-Personal-MBP";
      profile = "personal";
      system = "aarch64-darwin";
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
