# Recover the shell's working directory after an external volume is replugged.
#
# Why this exists: a process's cwd is a live reference to a directory, not a
# path string. Unplugging /Volumes/ext_ssd invalidates that reference, and every
# subsequent prompt in a shell that was sitting on the drive fails —
# `git status` reports "fatal: Unable to read current working directory", mise
# warns "Current directory does not exist or is not accessible", and so on. The
# reference cannot be repaired in place: only a chdir(2) re-resolves it, which is
# why typing `cd $PWD` by hand fixes the shell. This precmd hook does that `cd`.
#
# Detection has exactly one reliable probe, and it is a subprocess: /bin/pwd
# calls getcwd(3) fresh and exits non-zero when the cwd is unreachable. The
# tempting builtin alternatives are all wrong: zsh's own `pwd`, `[[ -d . ]]`,
# `zstat .` and `sysopen .` were each tested against a dead cwd and every one
# answered from the in-memory $PWD string (or from a vnode that outlives its
# directory) and reported success. Do not "optimise" the fork away; it costs
# ~1.3 ms and only runs while the cwd is on a watched volume.
#
# Scoping to cfg.volumes is what makes that acceptable: the `case` prefix test is
# pure string work, so a prompt anywhere else on the filesystem spawns nothing.
#
# In practice the prompt that notices the dead cwd arrives *while the drive is
# still absent* — you unplug, the next command fails, and that is the prompt the
# hook runs on. Re-entering $PWD therefore fails too, so the hook waits: it blocks
# the prompt until the directory exists again, then chdirs back into it. Blocking
# costs nothing you still had, because a shell with a dead cwd cannot run a single
# command successfully anyway; the alternative (relocate somewhere valid) loses the
# directory you were working in, which is the thing being protected.
#
# The wait is a `zselect -t 100` poll from zsh/zselect: no subprocess per tick, and
# a blocking syscall that SIGINT actually interrupts, so Ctrl-C escapes. It reports
# progress every 15s so a blocked prompt never looks like a frozen terminal.
#
# Giving up — Ctrl-C, or waitTimeout seconds if configured — parks the shell in
# $HOME and records the lost path in _hn_stale_cwd_pending. Later prompts retry
# that path cheaply (`[[ -d $pending ]]` resolves from the root, which is the right
# question here: "does that path exist", not "is my cwd alive") and return as soon
# as the volume is back. So an interrupted wait still recovers on its own.
#
# Parking in $HOME rather than the nearest surviving ancestor is deliberate: a
# quiet landing in /Volumes, or somewhere else on the drive, is how a later
# `git clean -fdx` or `rm -rf` runs against the wrong tree. $HOME is on the
# internal disk, always valid, and obviously not the repo you were in.
#
# That deferred return only fires while the shell is still sitting exactly where
# the hook parked it (_hn_stale_cwd_parked). `cd` somewhere by hand and the pending
# path is dropped — being yanked out of a directory you chose is the one thing
# worse than losing the original.
#
# `builtin cd` (not `cd -q`) on purpose: the chpwd hooks must run so mise,
# direnv and starship re-evaluate against the restored directory instead of
# holding state from the mount that went away.
#
# Limits: this only heals interactive zsh (home-manager writes ~/.zshrc, which
# non-interactive shells never read, so scripts and CI are untouched). Long-lived
# processes started from the drive — dev servers, watchers, language servers —
# each hold their own stale cwd and still have to be restarted.
{ config, lib, ... }:

let
  cfg = config.hn.staleCwdRecovery;

  # `/vol` matches the mount point itself, `/vol/*` anything under it. Both
  # sides are escaped so a volume name containing a space or a glob character
  # stays a literal prefix and cannot match a sibling like /Volumes/ext_ssd_old.
  volumePatterns = lib.concatStringsSep "|" (
    lib.concatMap (v: [
      (lib.escapeShellArg v)
      "${lib.escapeShellArg v}/*"
    ]) cfg.volumes
  );

  # Inlined into the arithmetic below; 0 disables the timeout branch entirely.
  waitTimeout = toString cfg.waitTimeout;
in
lib.mkIf cfg.enable {
  assertions = [
    {
      assertion = cfg.volumes != [ ];
      message = "hn.staleCwdRecovery.enable is true but volumes is empty; set the mount points to guard, e.g. [ \"/Volumes/ext_ssd\" ].";
    }
  ];

  programs.zsh.initContent = ''
    zmodload zsh/zselect 2>/dev/null
    zmodload zsh/datetime 2>/dev/null

    typeset -g _hn_stale_cwd_pending=""
    typeset -g _hn_stale_cwd_parked=""

    # Block until $1 exists. 0 = it came back, 1 = gave up (Ctrl-C or timeout).
    # zselect is an interruptible, fork-free tick; the SIGINT trap is function-local
    # (localtraps) so Ctrl-C ends the wait and nothing else.
    _hn_stale_cwd_wait() {
      local target=$1 interrupted=0 start=$EPOCHSECONDS elapsed=0 announced=0

      setopt localtraps
      trap 'interrupted=1' INT
      print -u2 "$target is not mounted - waiting for it (Ctrl-C to stop waiting)"

      while [[ ! -d $target ]]; do
        zselect -t 100 2>/dev/null
        (( interrupted )) && return 1

        elapsed=$(( EPOCHSECONDS - start ))
        (( ${waitTimeout} > 0 && elapsed >= ${waitTimeout} )) && return 1

        if (( elapsed / 15 > announced )); then
          announced=$(( elapsed / 15 ))
          print -u2 "still waiting for $target (''${elapsed}s)"
        fi
      done
      return 0
    }

    _hn_recover_stale_cwd() {
      # A previous wait was abandoned: retry the lost path cheaply, no subprocess.
      if [[ -n $_hn_stale_cwd_pending ]]; then
        if [[ $PWD != "$_hn_stale_cwd_parked" ]]; then
          # Moved on by hand; drop the claim rather than yank the shell later.
          _hn_stale_cwd_pending=""
          _hn_stale_cwd_parked=""
        elif [[ -d $_hn_stale_cwd_pending ]] && builtin cd -- "$_hn_stale_cwd_pending" 2>/dev/null; then
          print -u2 "volume is back - returned to $PWD"
          _hn_stale_cwd_pending=""
          _hn_stale_cwd_parked=""
          return
        else
          return
        fi
      fi

      # No subprocess unless the cwd is on a watched volume.
      case $PWD in
        ${volumePatterns}) ;;
        *) return ;;
      esac

      /bin/pwd >/dev/null 2>&1 && return

      local gone=$PWD

      # Already back at the same path: one chdir re-resolves the dead reference.
      if builtin cd -- "$gone" 2>/dev/null; then
        print -u2 "cwd was stale after a remount; re-entered $PWD"
        return
      fi

      # Not mounted yet - hold the prompt until it is.
      if _hn_stale_cwd_wait "$gone" && builtin cd -- "$gone" 2>/dev/null; then
        print -u2 "volume is back - resumed in $PWD"
        return
      fi

      # Gave up. Park somewhere usable, but keep the cheap retry armed so the
      # directory still comes back on its own if the volume returns later.
      builtin cd -- "$HOME" || return
      _hn_stale_cwd_pending=$gone
      _hn_stale_cwd_parked=$PWD
      print -u2 "stopped waiting for $gone - moved to $PWD (will return there if it comes back while you stay here)"
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _hn_recover_stale_cwd
  '';
}
