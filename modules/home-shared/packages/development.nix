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
    gh # GitHub CLI (auth, PRs, issues)
    # nix tooling
    nil # Nix language server (LSP)
    nixfmt # Nix formatter
    # python tooling. uv manages Python projects/installs itself, so it does
    # NOT need a nix-pinned interpreter to be useful; mise/miniconda still
    # provide per-project runtimes elsewhere.
    uv # Astral's Python package + project manager (https://docs.astral.sh/uv/)
    # AI coding agents. Claude Code is deliberately absent: it self-updates,
    # which a nix-managed binary cannot do.
    codex # OpenAI Codex CLI
  ];
}
