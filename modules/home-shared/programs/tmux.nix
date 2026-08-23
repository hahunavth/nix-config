# tmux — sessions that outlive the terminal window.
#
# The reason it is worth having here rather than only on servers: the long-lived
# work is ssh into the homelab over Tailscale, and a dropped link takes the
# shell with it unless something is holding the session.
#
# The default C-b prefix is kept deliberately — remapping it makes every remote
# tmux and every copied instruction wrong.
{ ... }:

{
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    historyLimit = 50000;
    escapeTime = 10;
    terminal = "tmux-256color";
    # renumber-windows: close window 2 of 3 and the third becomes 2, so indices
    # stay contiguous and prefix-<n> keeps meaning what it looks like.
    #
    # terminal-overrides Tc: advertise truecolor to programs running inside tmux.
    # Without it the prompt and editors fall back to 256 colours even in a
    # capable terminal.
    #
    # Comments stay out here on purpose: anything inside this string is written
    # verbatim into the generated tmux.conf.
    extraConfig = ''
      set -g renumber-windows on
      set -ga terminal-overrides ",*256col*:Tc"   # truecolor passthrough
    '';
  };
}
