{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.hn.atlassian.enable {
  # Make the JDK + SDK follow the git BRANCH, not the checkout.
  #
  # The problem this solves: one plugin repo has branches on both SDK
  # generations, so the correct toolchain changes on every `git switch` — and a
  # committed .mise.toml cannot express that, since it is itself versioned per
  # branch and would conflict on every merge.
  #
  # So: run `atlas-mise-enable` once in a repo to install post-checkout,
  # post-merge and post-rewrite hooks. Each regenerates a GITIGNORED
  # .mise.local.toml from the branch name — "wiki_9" in the name means Java 17
  # + SDK 9.1.1, anything else Java 8 + SDK 8.2.7. The rule itself lives in
  # NEW_STACK_PATTERN in ../scripts/atlassian-mise/atlas-mise-gen.sh.
  #
  # Nothing is written into a tracked file, and the prompt shows which SDK is
  # live (the custom.atlassian_sdk module in ./starship.nix reads the same file).
  home.packages = [
    (pkgs.writeShellScriptBin "atlas-mise-gen" (
      builtins.readFile ../scripts/atlassian-mise/atlas-mise-gen.sh
    ))
    (pkgs.writeShellScriptBin "atlas-mise-enable" (
      builtins.readFile ../scripts/atlassian-mise/atlas-mise-enable.sh
    ))
  ];
}
