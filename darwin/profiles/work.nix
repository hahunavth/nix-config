# Work profile Homebrew overrides (differences from common.nix only).
(import ./lib.nix).mkProfile {
  extraCasks = [
    "microsoft-office" # Word, Excel, PowerPoint, OneNote
    "microsoft-teams"
    "remote-desktop-manager"
    "slack"
    "zoom"
  ];
}
