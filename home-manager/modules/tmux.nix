{ ... }:

{
  # Persistent, reconnectable local terminal sessions (useful for the many
  # SSH sessions to the Tailscale homelab). Default C-b prefix kept.
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    historyLimit = 50000;
    escapeTime = 10;
    terminal = "tmux-256color";
    extraConfig = ''
      set -g renumber-windows on
      set -ga terminal-overrides ",*256col*:Tc"   # truecolor passthrough
    '';
  };
}
