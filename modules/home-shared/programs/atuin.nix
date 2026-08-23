# Atuin: SQLite-backed shell history with a better Ctrl-R and optional
# end-to-end-encrypted sync across machines (Mac <-> the OrbStack VM <-> future
# hosts). Opt-in per host via `hn.atuin.enable = true` because it takes over
# Ctrl-R from fzf (see fzf.nix).
#
# Sync is off until you run `atuin register` / `atuin login` and `atuin sync`;
# enabling this module alone only gives the local history DB + search.
{ config, lib, ... }:
lib.mkIf config.hn.atuin.enable {
  programs.atuin = {
    enable = true;
    # Keep Up-arrow as plain shell history; Atuin owns Ctrl-R only.
    flags = [ "--disable-up-arrow" ];
    settings = {
      style = "compact";
      # Sync cadence is honoured only after you authenticate a sync account.
      auto_sync = true;
      sync_frequency = "5m";
      update_check = false;
    };
  };
}
