# git + delta. Identity comes from the global `identity` in flake.nix (threaded
# in as `userConfig`) — never hardcode a name or email here.
#
# Two identities, selected by PATH: the personal email is the default, and any
# repo whose path contains a "KOD" folder gets the work email via
# programs.git.includes. Nothing about the remote is inspected, so a work repo
# cloned outside a KOD folder will quietly commit as the personal identity —
# check `git config user.email` if that matters.
{ userConfig, ... }:

{
  programs.git = {
    enable = true;

    # Git LFS: installs git-lfs and writes the filter.lfs clean/smudge/process
    # config into ~/.config/git/config, which is exactly what `git lfs install`
    # does by hand — so do NOT run that (it would try to write the same keys and
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
