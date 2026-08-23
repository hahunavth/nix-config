{ pkgs, ... }:

{
  # mise — the runtime version manager, and the sole owner of LANGUAGE RUNTIME
  # versions on every host (this module is not feature-gated).
  #
  # Who owns what, so nothing is installed twice:
  #   mise      node + pnpm, and all three JDKs — the globals below
  #   conda     python, from the miniconda cask; shell init is wired up in
  #             modules/darwin/home/conda.nix (macOS only)
  #   nix       CLI tools (modules/home-shared/packages/) and the Atlassian
  #             Plugin SDK — pinned in pkgs/atlassian-plugin-sdk and exposed at
  #             stable paths by programs/atlassian-sdk.nix. mise does NOT
  #             install or version the SDK; a project only puts the matching
  #             bin dir on PATH with `_.path` in its .mise.toml.
  #   homebrew  GUI apps (modules/darwin/homebrew/casks/)
  #
  # Scope: the globals below are only the fallback for a directory with no mise
  # config of its own. Per-project versions live in that repo's .mise.toml, and
  # in Atlassian plugin repos a gitignored .mise.local.toml is regenerated per
  # git branch by atlas-mise (hn.atlassian) — Java 17 + SDK 9.1.1 for wiki_9
  # branches, else Java 8 + SDK 8.2.7. Pairing rules: AGENTS.md "Dev toolchains".
  #
  # Caveat worth knowing: tool versions resolve at `mise install` time, over the
  # network — NOT at nix build time. A green `darwin-rebuild switch` therefore
  # says nothing about whether a runtime is actually on disk; that is the trade
  # for being able to pin a version per project. When a reproducible ad-hoc
  # runtime is what's wanted instead, use a dev shell: `nix develop .#node`
  # (also .#python, .#atlassian — see shells/).
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    globalConfig = {
      settings = {
        # Implicitly trust mise configs under the work-repos root, so the
        # atlas-mise-generated .mise.local.toml never hits the trust prompt
        # (trust is stored per-path and breaks on renames/moves otherwise).
        # /Volumes/ext_ssd is the macOS external drive; meaningless on Linux.
        trusted_config_paths = pkgs.lib.optionals pkgs.stdenv.isDarwin [ "/Volumes/ext_ssd" ];
      };

      tools = {
        node = "lts";
        pnpm = "11";
        # All three JDKs are installed; the first is the global default.
        # Atlassian plugin projects pin the matching version in their .mise.toml.
        java = [
          "temurin-25"
          "temurin-17"
          "zulu-8" # Java 8 uses Zulu — Temurin has no arm64 JDK 8 for Apple Silicon.
        ];
      };
    };
  };
}
