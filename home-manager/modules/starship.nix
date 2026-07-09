{ ... }:

{
  # starship prompt (automatically wired into zsh)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # Powerline "pill" style: each segment is a self-contained rounded block
      # (leading  + colored bg + trailing ), so conditional language modules
      # don't break the color chain. Needs a Nerd Font (you have one).

      # Full working-directory path in a blue pill.
      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
        format = "[](fg:24)[ $path ](fg:231 bg:24)[](fg:24) ";
      };

      git_branch = {
        symbol = " ";
        format = "[](fg:54)[ $symbol$branch ](fg:231 bg:54)[](fg:54) ";
      };

      nodejs = {
        symbol = " "; # Node.js hexagon logo (Nerd Font)
        format = "[](fg:34)[ $symbol$version ](fg:16 bg:34)[](fg:34) ";
      };
      java = {
        symbol = " "; # Java logo (Nerd Font)
        format = "[](fg:124)[ $symbol$version ](fg:231 bg:124)[](fg:124) ";
      };
      python = {
        symbol = " "; # Python logo (Nerd Font)
        format = "[](fg:25)[ $symbol$version ](fg:231 bg:25)[](fg:25) ";
      };
      package = {
        symbol = " "; # box (Nerd Font)
        format = "[](fg:240)[ $symbol$version ](fg:231 bg:240)[](fg:240) ";
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
        format = "[](fg:27)[ $symbol$output ](fg:231 bg:27)[](fg:27) ";
      };
    };
  };
}
