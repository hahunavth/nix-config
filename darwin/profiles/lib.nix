# Helper for profile-specific Homebrew overrides.
# Profiles describe only what differs from darwin/profiles/common.nix:
# extra* lists add packages; remove* lists subtract shared ones.
{
  mkProfile =
    {
      extraTaps ? [ ],
      extraBrews ? [ ],
      extraCasks ? [ ],
      removeTaps ? [ ],
      removeBrews ? [ ],
      removeCasks ? [ ],
      masApps ? { },
    }:
    {
      inherit
        extraTaps
        extraBrews
        extraCasks
        removeTaps
        removeBrews
        removeCasks
        masApps
        ;
    };
}
