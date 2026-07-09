# Regenerate .mise.local.toml for the current git branch.
# Shebang is provided by writeShellScriptBin (runtimeShell = bash).
set -euo pipefail

# Branch substring that selects the NEW stack (Java 17 + Atlassian SDK 9.1.1).
# Everything else gets the OLD stack (Java 8 + Atlassian SDK 8.2.7).
NEW_STACK_PATTERN='wiki_9'

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
branch=$(git -C "$root" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')

if [[ "$branch" == *"$NEW_STACK_PATTERN"* ]]; then
  java='temurin-17'
  sdk_bin="$HOME/.local/share/atlassian-plugin-sdk/9.1.1/bin"
  label='Java 17 + Atlassian SDK 9.1.1'
else
  java='zulu-8'
  sdk_bin="$HOME/.local/share/atlassian-plugin-sdk/8.2.7/bin"
  label='Java 8 (Zulu) + Atlassian SDK 8.2.7'
fi

cat > "$root/.mise.local.toml" <<EOF
# AUTO-GENERATED from the git branch ("$branch") by the atlas-mise hook.
# $label. Do not edit by hand — change the branch, or edit NEW_STACK_PATTERN
# in atlas-mise-gen. Keep this file gitignored.
[tools]
java = "$java"

[env]
_.path = ["$sdk_bin"]
EOF

# mise requires trusting config that sets env
if command -v mise >/dev/null 2>&1; then
  mise trust "$root/.mise.local.toml" >/dev/null 2>&1 || true
fi

echo "atlas-mise: branch '$branch' -> $label" >&2
