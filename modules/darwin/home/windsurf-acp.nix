# Windsurf IDE Agent Control Protocol (ACP) registry.
#
# Windsurf reads ~/.windsurf/acp/registry.json to discover ACP-compatible
# agents it can spawn from its agent picker. The JSON is owned verbatim by
# Windsurf's schema, so it lives next to this module as a real file rather
# than being interpolated through a Nix string — that way the JSON stays
# validatable with any JSON tool and edits don't risk escaping bugs.
#
# This is macOS-only because Windsurf itself is a macOS GUI app. If a Linux
# host ever installs Windsurf, move the file under a hn.* toggle.
{ ... }:

{
  home.file.".windsurf/acp/registry.json".source = ./windsurf-acp/registry.json;
}
