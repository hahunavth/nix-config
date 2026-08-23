# zsh — generates ~/.zshrc, and is the hub every other shell integration hangs
# off. starship, mise, fzf, zoxide, direnv, atuin and eza each add their own
# init here from their own module; enabling this is what makes all of that fire.
#
# The generated ~/.zshrc is a read-only store symlink, so nothing may edit it
# in place — that is why conda goes through initContent (darwin/home/conda.nix)
# instead of `conda init`, and the same applies to any installer offering to
# "add a line to your .zshrc".
#
# Interactive shells only. Session VARIABLES land in ~/.zshenv (read by
# non-interactive zsh too) and login-shell setup in ~/.zprofile
# (darwin/home/login-shell.nix) — three different files, three different scopes.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Aliases live in ../aliases/, split by domain. They are plain imports
    # rather than modules, so they cannot read `config` themselves — this is
    # the layer that resolves the hn.* flag and passes the answer down.
    shellAliases = import ../aliases {
      inherit lib pkgs;
      homelabTunnel = config.hn.homelabTunnel.enable;
    };
    # No platform conditionals in this file. Anything macOS-only appends to
    # programs.zsh.initContent from its own module in modules/darwin/home/,
    # and home-manager merges the fragments.

    # oh-my-zsh from nixpkgs — no curl-into-shell installer, and no ~/.oh-my-zsh
    # checkout to keep updated.
    #
    # Kept mainly for its lib/key-bindings.zsh, which binds Up/Down to
    # up-line-or-beginning-search: history search filtered by what is already
    # typed. No theme is set — starship's init runs after omz and wins.
    #
    # Plugins are cheap here but not free; each is sourced at every shell start,
    # so the list stays short and deliberate.
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git" # g* aliases (g, gst, gco, ...) + branch info in completions
        # "z" deliberately absent: zoxide owns `z` (see ./zoxide.nix). Enabling
        # both makes whichever loads last silently win.
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
