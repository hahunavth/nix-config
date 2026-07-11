# conda (miniconda Homebrew cask) shell init — macOS-only, so it lives in the
# darwin home layer rather than the cross-platform shared zsh module.
#
# Sourcing conda.sh defines the `conda` shell function without auto-activating
# base (and is faster than the conda hook eval). Do NOT run `conda init` — it
# would try to edit the read-only ~/.zshrc. `programs.zsh.initContent` merges
# with the shared zsh config.
{ ... }:

{
  programs.zsh.initContent = ''
    if [ -f /opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh ]; then
      source /opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh
    fi
  '';
}
