{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    claude-code   # Claude Code CLI
    socat
  ];
}
