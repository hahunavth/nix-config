{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "hahunavth";
        email = "vuthanhha@kodnet.co.jp";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # Make diffs easier to read
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
