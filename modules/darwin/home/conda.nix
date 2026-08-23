# conda shell init, from the miniconda Homebrew cask.
#
# conda is the one language runtime mise does NOT own here: Python and the
# data-science stack come from conda instead (see
# modules/home-shared/programs/mise.nix for the full ownership split). macOS-only
# because the cask is, hence this layer rather than the shared zsh module.
#
# NEVER run `conda init`. It works by editing ~/.zshrc, which home-manager
# generates as a read-only store symlink — so it fails, and would be overwritten
# on the next switch even if it did not. This block is the declarative
# equivalent, appended through programs.zsh.initContent (home-manager merges the
# fragments from every module).
#
# Sourcing conda.sh rather than `eval "$(conda shell.hook)"`: it defines the
# `conda` function without activating `base`, and skips a python start-up per
# shell. Nothing is activated until you ask — `conda activate <env>`.
{ ... }:

{
  programs.zsh.initContent = ''
    if [ -f /opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh ]; then
      source /opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh
    fi
  '';
}
