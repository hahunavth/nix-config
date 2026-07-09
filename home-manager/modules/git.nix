{ userConfig, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = userConfig.githubUsername;
        # Personal identity is the default everywhere...
        email = userConfig.email;
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
    # ...but any repo whose path contains a "KOD" folder uses the work identity.
    includes = [
      {
        condition = "gitdir:**/*KOD*/**";
        contents.user.email = userConfig.workEmail;
      }
    ];
  };

  # Make diffs easier to read
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
