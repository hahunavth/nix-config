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

    # oh-my-zsh, installed declaratively from nixpkgs (no curl installer).
    # Its lib/key-bindings.zsh gives prefix-aware Up/Down history search
    # (up-line-or-beginning-search) out of the box. The prompt stays
    # starship's: its init runs after omz and overrides the theme.
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git" # g* aliases + git status in completions
        "z" # jump to frecent dirs: `z <partial-path>`
        "sudo" # double-tap Esc to prepend sudo
        "extract" # `extract <archive>` for any format
        "docker" # docker completions + dk* aliases
        "npm" # npm completions + aliases
        "colored-man-pages"
        "command-not-found"
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        "macos" # ofd (open Finder), cdf, quick-look, ...
      ];
    };
  };
}
