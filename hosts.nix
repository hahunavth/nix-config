# Machine & identity registry (see hosts.example.nix for the template).
# Validated and enriched by lib/hosts.nix; the flake builds one
# darwinConfigurations entry per host below.
{
  common = {
    fullName = "hahunavth";
    githubUsername = "hahunavth";
    # Personal identity is the git default everywhere...
    email = "vuthanhha.2001@gmail.com";
    # ...but repos under a KOD folder use the work identity (see modules/git.nix).
    workEmail = "vuthanhha@kodnet.co.jp";
    signingKey = ""; # Set when commit signing is configured
  };

  hosts = {
    work = {
      username = "kod_admin";
      hostname = "KOD-ADMINs-MacBook-Pro";
      profile = "work";
    };

    # personal = {
    #   username = "...";
    #   hostname = "...";
    #   profile = "personal";
    # };
  };
}
