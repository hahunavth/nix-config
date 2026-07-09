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
    };

    personal = {
      username = "you";
      hostname = "Your-Personal-MBP";
      profile = "personal";
    };
  };
}
