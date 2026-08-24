# A second Claude Code profile — its own login, one shared set of skills.
#
# CLAUDE_CONFIG_DIR is the whole mechanism: Claude Code reads settings, session
# state *and* its credentials out of that directory, so relocating it is what
# buys a separate account rather than a second window on the same one. Checked
# rather than assumed — with ~/.claude-1 in place, `claude-1 -p ...` answers
# "Not logged in · Please run /login" while the default profile stays signed in.
#
# What the two profiles share is decided inside ~/.claude-1, not here: skills/,
# plugins/ and the statusline are symlinks back into ~/.claude, so editing one
# copy moves both, while settings.json and the session directories are real
# files per profile. Project MCP servers come from each repo's .mcp.json and are
# not config-dir scoped, so they need no arrangement either way.
#
# That directory is deliberately outside nix — it holds live session state and
# credentials, which a read-only store symlink cannot be. The alias only needs
# it to exist; `claude` creates what is missing on first run.
#
# $HOME reaches zsh unexpanded: nix interpolates ${...}, never $NAME, and an
# alias is expanded at call time regardless.
{ ... }:
let
  secondProfile = "CLAUDE_CONFIG_DIR=$HOME/.claude-1 claude";
in
{
  claude-1 = secondProfile;
  c1 = secondProfile;
}
