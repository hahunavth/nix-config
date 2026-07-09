# Shared base packages for all macOS profiles, composed from the categorized
# lists in darwin/homebrew-packages/.
let
  homebrewPackages = ../homebrew-packages;
in
{
  taps = import (homebrewPackages + "/taps.nix");

  brews = import (homebrewPackages + "/brews/core.nix");

  casks =
    (import (homebrewPackages + "/casks/apps.nix"))
    ++ (import (homebrewPackages + "/casks/development.nix"))
    ++ (import (homebrewPackages + "/casks/system.nix"));

  masApps = { };
}
