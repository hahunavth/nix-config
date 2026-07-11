# Development / search CLI tools.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    nil # Nix language server (LSP)
    nixfmt # Nix formatter
  ];
}
