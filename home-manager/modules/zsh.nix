{ lib, ... }:

{
  # Manage zsh with home-manager (generates ~/.zshrc)
  # This is what enables the zsh integrations for starship / mise / neovim etc.
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Aliases live in home-manager/aliases/, split by domain
    shellAliases = import ../aliases { inherit lib; };

    # conda (miniconda Homebrew cask): make `conda activate` work in the
    # hm-managed zsh. Do NOT run `conda init` — it would try to edit the
    # read-only ~/.zshrc. Sourcing conda.sh defines the shell function
    # without auto-activating base (and is faster than the conda hook eval).
    initContent = ''
      if [ -f /opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh ]; then
        source /opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh
      fi
    '';
  };
}
