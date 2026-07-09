# Work-machine overrides layered on top of profiles/common.nix.
{
  homebrew = {
    extraTaps = [ ];
    removeTaps = [ ];
    extraBrews = [ ];
    removeBrews = [ ];
    extraCasks = [
      "microsoft-office" # Word, Excel, PowerPoint, OneNote
      "microsoft-teams"
      "remote-desktop-manager"
      "slack"
      "zoom"
    ];
    removeCasks = [ ];
    masApps = { };
  };
}
