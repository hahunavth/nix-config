# Shared base packages for all macOS profiles, composed from the categorized
# lists one level up (modules/darwin/homebrew/{taps,brews,casks}).
let
  homebrewPackages = ../.;
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
