{ ... }:

{
  # Homebrew integration (for GUI apps not well-suited to nixpkgs)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";   # removes casks/formulae not listed here on rebuild
      extraFlags = [ "--verbose" ];   # <-- shows real per-cask progress
    };

    casks = [
      "claude"                 # Claude desktop app
      "slack"
      "arc"
      "google-chrome"
      "microsoft-edge"
      "visual-studio-code"
      "microsoft-office"       # Word, Excel, PowerPoint, OneNote
      "microsoft-teams"
      "remote-desktop-manager"
      "orbstack"               # Docker/Linux VMs (Docker Desktop alternative)
      "warp"                   # Warp terminal
      "sublime-text"
      "bitwarden"              # Bitwarden password manager
      "tailscale-app"          # Tailscale mesh VPN (GUI + menu-bar app)
    ];
  };
}
