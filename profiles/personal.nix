# Personal-machine overrides layered on top of profiles/common.nix.
# Scaffold for a future personal machine — add e.g. spotify, discord here.
{
  homebrew = {
    extraTaps = [ ];
    removeTaps = [ ];
    extraBrews = [ ];
    removeBrews = [ ];
    extraCasks = [ ];
    removeCasks = [ ];
    masApps = { };
  };
}
