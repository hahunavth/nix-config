{ userConfig, ... }:

{
  programs.git = {
    enable = true;

    # Git LFS: installs git-lfs and writes the filter.lfs clean/smudge/process
    # config into ~/.config/git/config, which is exactly what `git lfs install`
    # does by hand -- so do NOT run that (it would try to write the same keys and
    # the generated config is read-only anyway). Per-repo setup is unchanged:
    # `git lfs track "*.psd"` in the repo, then commit the .gitattributes.
    lfs.enable = true;

    settings = {
      user = {
        name = userConfig.githubUsername;
        # Personal identity is the default everywhere...
        email = userConfig.email;
      };
      init.defaultBranch = "main";
      # pull.rebase = true;
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
