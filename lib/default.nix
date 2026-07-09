{ lib }:

{
  # (base ++ extra) with any `remove` entries filtered out.
  # Used to compose per-profile Homebrew lists from a common base.
  composeList =
    base: extra: remove:
    lib.filter (x: !(builtins.elem x remove)) (base ++ extra);
}
