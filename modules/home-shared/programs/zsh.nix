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

    # Up/Down search history by the already-typed prefix (like oh-my-zsh),
    # instead of stepping through it one entry at a time. Covers both normal
    # ("^[[A") and application ("^[OA") cursor-key modes.
    initContent = ''
      autoload -U up-line-or-beginning-search down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey "^[[A" up-line-or-beginning-search
      bindkey "^[OA" up-line-or-beginning-search
      bindkey "^[[B" down-line-or-beginning-search
      bindkey "^[OB" down-line-or-beginning-search
    '';
  };
}
