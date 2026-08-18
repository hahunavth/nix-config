{ lib, ... }:

let
  # Nerd Font glyphs by codepoint. They MUST be written as JSON \u escapes and
  # decoded via fromJSON: literal private-use-area characters do not survive the
  # tooling that edits this file (they were silently stripped before, which is
  # why the prompt rendered as flat colored blocks with no separators at all).
  # Verified present in nerd-fonts.jetbrains-mono (modules/darwin/fonts.nix).
  g = cp: builtins.fromJSON ''"\u${cp}"'';

  sep = g "e0b0"; # hard right-pointing separator / tail (U+E0B0)

  icon = {
    git = g "e725"; # git branch
    node = g "e718"; # Node.js
    java = g "e738"; # Java
    python = g "e73c"; # Python
    package = g "f487"; # package
    docker = g "e7b0"; # Docker
    nix = g "f313"; # Nix snowflake
    lock = g "f023"; # read-only directory
  };

  # Powerline zone palette (256-color indices). The prompt is ONE contiguous bar
  # split into zones; each zone owns a background and the sep between two zones
  # is drawn with fg = previous zone's bg, bg = next zone's bg (the p10k look).
  #
  # The zone separators live in the top-level `format`, not in the modules: a
  # module's own format cannot know which module rendered before it, so putting
  # transitions there is the only way the color chain stays correct when
  # optional modules (git, languages) are absent. Cost: an empty zone collapses
  # to a 1-char gradient sliver instead of disappearing.
  dirBg = "24"; # cwd - dark blue
  gitBg = "54"; # git - purple
  envBg = "238"; # toolchains / env - dark grey, colored icons
  txt = "231"; # near-white text on the saturated zones
  dim = "252"; # softer text for versions on grey
in
{
  # starship prompt (automatically wired into zsh)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      format = lib.concatStrings [
        # No left cap: the bar starts flush at the left edge.
        "$directory"
        "[${sep}](fg:${dirBg} bg:${gitBg})" # cwd -> git
        "$git_branch$git_status"
        "[${sep}](fg:${gitBg} bg:${envBg})" # git -> env
        "$nodejs$java$python$package"
        "\${custom.atlassian_sdk}"
        "$docker_context$nix_shell"
        "[${sep}](fg:${envBg})" # tail
        "$line_break$character"
      ];

      # Full working-directory path, no truncation.
      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
        read_only = " ${icon.lock}";
        format = "[ $path$read_only ](fg:${txt} bg:${dirBg})";
      };

      git_branch = {
        symbol = "${icon.git} ";
        format = "[ $symbol$branch ](fg:${txt} bg:${gitBg})";
      };
      # Conditional group: prints nothing (not even padding) on a clean repo.
      git_status.format = "([$all_status$ahead_behind ](fg:${txt} bg:${gitBg}))";

      # Toolchain zone: colored icon, neutral version text, shared background.
      nodejs = {
        symbol = "${icon.node} ";
        format = "[ $symbol](fg:114 bg:${envBg})[$version ](fg:${dim} bg:${envBg})";
      };
      java = {
        symbol = "${icon.java} ";
        format = "[ $symbol](fg:209 bg:${envBg})[$version ](fg:${dim} bg:${envBg})";
      };
      python = {
        symbol = "${icon.python} ";
        format = "[ $symbol](fg:117 bg:${envBg})[$version ](fg:${dim} bg:${envBg})";
      };
      package = {
        symbol = "${icon.package} ";
        format = "[ $symbol](fg:180 bg:${envBg})[$version ](fg:${dim} bg:${envBg})";
      };
      docker_context = {
        symbol = "${icon.docker} ";
        format = "[ $symbol](fg:75 bg:${envBg})[$context ](fg:${dim} bg:${envBg})";
      };
      nix_shell = {
        symbol = "${icon.nix} ";
        format = "[ $symbol](fg:81 bg:${envBg})[$name ](fg:${dim} bg:${envBg})";
      };

      # Active Atlassian Plugin SDK version, only in enabled plugin repos.
      custom.atlassian_sdk = {
        description = "Active Atlassian Plugin SDK version";
        detect_files = [ ".mise.local.toml" ];
        when = "grep -q atlassian-plugin-sdk .mise.local.toml";
        command = "grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+' .mise.local.toml | head -1";
        shell = [
          "bash"
          "--noprofile"
          "--norc"
        ];
        symbol = "◆ ";
        format = "[ $symbol](fg:111 bg:${envBg})[$output ](fg:${dim} bg:${envBg})";
      };
    };
  };
}
