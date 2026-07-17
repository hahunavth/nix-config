#!/bin/sh
# PostToolUse(Edit|Write): format an edited .nix file with the flake formatter
# (treefmt + pinned nixfmt-rfc-style, byte-identical to CI's `nix fmt` check).
# Fail-safe: always exits 0; never blocks Claude.
f=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$f" ] || exit 0
case "$f" in
  *.nix) ;;
  *) exit 0 ;;
esac
case "$f" in
  # treefmt excludes these itself; skip early to avoid the nix fmt startup cost
  */modules/nixos/orbstack/* | */tmp/*) exit 0 ;;
esac
[ -f "$f" ] || exit 0
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
nix fmt -- "$f" >/dev/null 2>&1
exit 0
