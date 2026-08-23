# Atuin — shell history in SQLite instead of a flat file, with a searchable
# Ctrl-R and optional end-to-end-encrypted sync between machines.
#
# Opt-in (hn.atuin.enable) rather than on by default, because it TAKES OVER
# Ctrl-R from fzf (./fzf.nix) — a muscle-memory change, not an addition.
#
# Enabling this module gets the local database and search only. Sync stays
# dormant until you run `atuin register` (or `login`) and `atuin sync` by hand,
# since it needs an account and a key that cannot come from nix.
{ config, lib, ... }:
lib.mkIf config.hn.atuin.enable {
  programs.atuin = {
    enable = true;
    # Up-arrow stays plain zsh history (prefix-aware, via oh-my-zsh's
    # key-bindings). Atuin's full-screen UI is reserved for Ctrl-R, so the
    # cheap case keeps working the way it always did.
    flags = [ "--disable-up-arrow" ];
    settings = {
      style = "compact";
      # Inert until an account is authenticated — with no credentials there is
      # nothing to sync and these are simply ignored.
      auto_sync = true;
      sync_frequency = "5m";
      update_check = false;
    };
  };
}
