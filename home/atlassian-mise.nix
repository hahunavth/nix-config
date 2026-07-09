{ pkgs, ... }:

{
  # Per-project branch-based switching of Java + Atlassian SDK.
  # In an Atlassian plugin repo run `atlas-mise-enable` once; thereafter every
  # `git checkout`/switch rewrites .mise.local.toml so mise activates the right
  # JDK and puts the matching atlas-* SDK on PATH. Branch rule: name contains
  # "wiki_9" -> Java 17 + SDK 9.1.1, otherwise Java 8 + SDK 8.2.7. See CLAUDE.md.
  home.packages = [
    (pkgs.writeShellScriptBin "atlas-mise-gen" (builtins.readFile ./atlassian-mise/atlas-mise-gen.sh))
    (pkgs.writeShellScriptBin "atlas-mise-enable" (builtins.readFile ./atlassian-mise/atlas-mise-enable.sh))
  ];
}
