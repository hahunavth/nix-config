#!/bin/sh
# PreToolUse(Bash): before nix build/eval/flake check or *-rebuild, stage
# everything — flakes ignore untracked files (the #1 gotcha in this repo).
# Fail-safe: always exits 0; never blocks the tool call.
cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[ -n "$cmd" ] || exit 0
case "$cmd" in
  *"nix build"* | *"nix eval"* | *"nix flake check"* | *darwin-rebuild* | *nixos-rebuild*)
    [ -f "${CLAUDE_PROJECT_DIR}/flake.nix" ] || exit 0
    git -C "${CLAUDE_PROJECT_DIR}" add -A >/dev/null 2>&1
    ;;
esac
exit 0
