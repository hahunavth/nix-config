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

  # diffを見やすくする
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
