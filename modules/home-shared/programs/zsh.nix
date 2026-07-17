{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Manage zsh with home-manager (generates ~/.zshrc)
  # This is what enables the zsh integrations for starship / mise / neovim etc.
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Aliases live in modules/home-shared/aliases/, split by domain.
    # win-tunnel forwards are gated behind the winTunnel feature.
    shellAliases = import ../aliases {
      inherit lib pkgs;
      winTunnel = config.hn.winTunnel.enable;
    };
    # Platform-specific shell init is added by its own module, e.g. conda lives
    # in modules/darwin/home/conda.nix (macOS-only) — this module stays generic.

    # Up/Down search history by what's already typed, via the
    # zsh-history-substring-search plugin (the behavior oh-my-zsh ships by
    # default on non-nix machines). PREFIXED=1 limits matches to commands
    # STARTING with the typed text; remove it to match anywhere in the line.
    # Key codes cover both normal ("^[[A") and application ("^[OA") modes.
    historySubstringSearch = {
      enable = true;
      searchUpKey = [
        "^[[A"
        "^[OA"
      ];
      searchDownKey = [
        "^[[B"
        "^[OB"
      ];
    };
    localVariables.HISTORY_SUBSTRING_SEARCH_PREFIXED = 1;
  };
}
