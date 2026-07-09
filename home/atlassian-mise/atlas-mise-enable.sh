# Enable branch-based Java/Atlassian-SDK switching in the current git repo.
# Shebang is provided by writeShellScriptBin (runtimeShell = bash).
set -euo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo 'atlas-mise: not inside a git repo' >&2
  exit 1
}
hooks="$root/.git/hooks"
mkdir -p "$hooks"

for h in post-checkout post-merge post-rewrite; do
  target="$hooks/$h"
  if [[ -e "$target" ]] && ! grep -q atlas-mise-gen "$target" 2>/dev/null; then
    echo "atlas-mise: $target already exists; add 'atlas-mise-gen' to it yourself" >&2
    continue
  fi
  cat > "$target" <<'HOOK'
#!/usr/bin/env bash
# Installed by atlas-mise-enable: switch Java + Atlassian SDK by branch.
exec atlas-mise-gen
HOOK
  chmod +x "$target"
done

# Keep the generated local override out of the project's history
gi="$root/.gitignore"
if ! grep -qxF '.mise.local.toml' "$gi" 2>/dev/null; then
  echo '.mise.local.toml' >> "$gi"
fi

# Generate for the current branch now
atlas-mise-gen

echo "atlas-mise: enabled in $root" >&2
