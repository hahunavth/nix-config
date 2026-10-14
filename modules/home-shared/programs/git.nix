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

      # Sign every commit and tag with an SSH key. `gpg.format ssh` means git
      # shells out to ssh-keygen, not gpg — no gpg install needed, and the
      # signature is a plain SSH signature block in the commit object.
      #
      # The key itself (hahunavth_signing) is a plain file in ~/.ssh, NOT
      # managed by nix, matching the other private keys — see
      # programs/ssh.nix. Its public half is also registered on the GitHub
      # account under Settings > SSH and GPG keys > "Signing keys", or GitHub
      # vigilant mode shows every commit as "Unverified".
      commit.gpgsign = true;
      tag.gpgsign = true;
      gpg.format = "ssh";
      user.signingKey = "~/.ssh/hahunavth_signing.pub";
      # Without this, `git log --show-signature` errors out instead of
      # verifying. The file is plain `key principal` lines, mode 644.
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";

      # HTTPS auth to GitHub through gh's stored token. Declared here because
      # ~/.config/git/config is generated read-only: `gh auth setup-git` (or an
      # agent doing it for you) has to replace that file to write this line,
      # and the next activation puts the generated one back, silently dropping
      # the helper. SSH remotes are unaffected (ssh-agent / ssh.nix).
      credential."https://github.com".helper = "!gh auth git-credential";
      credential."https://gist.github.com".helper = "!gh auth git-credential";
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
