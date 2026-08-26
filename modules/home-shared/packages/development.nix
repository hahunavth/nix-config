# Development / search CLI tools, on every host.
#
# Plain binaries only. Anything needing configuration belongs in
# ../programs/<name>.nix instead, where it gets typed options and shell
# integration (fd and jq are here; fzf and eza are not, because they are
# configured).
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # common utils
    ripgrep
    fd
    jq
    # nix tooling
    nil # Nix language server (LSP)
    nixfmt # Nix formatter
    # AI coding agents. Claude Code is deliberately absent: it self-updates,
    # which a nix-managed binary cannot do.
    codex # OpenAI Codex CLI
  ];
}
