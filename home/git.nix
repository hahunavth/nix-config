{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "hahunavth";
        # Personal identity is the default everywhere...
        email = "vuthanhha.2001@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
    # ...but any repo whose path contains a "KOD" folder uses the work identity.
    includes = [
      {
        condition = "gitdir:**/*KOD*/**";
        contents.user.email = "vuthanhha@kodnet.co.jp";
      }
    ];
  };

  # Make diffs easier to read
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
