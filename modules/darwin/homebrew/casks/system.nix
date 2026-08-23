# Menu-bar and system utilities for every macOS host.
#
# Several of these own a job that this config deliberately does NOT automate in
# Lua or nix: rectangle does window snapping, raycast the launcher and
# clipboard, input-source-pro per-app input methods. hammerspoon is left with
# only the event-driven work nothing else covers — see
# modules/darwin/home/hammerspoon.nix.
[
  "tailscale-app" # Tailscale mesh VPN (GUI + menu-bar app)
  "input-source-pro" # Auto-switch keyboard input source per app/site
  "syncthing-app"
  "rectangle" # Window snapping / management
  "notunes" # Prevent iTunes / Apple Music from auto-launching
  "shottr" # Screenshot tool w/ annotation
  "hammerspoon" # Lua automation: URL routing, volume watch, copy/paste sounds (modules/darwin/home/hammerspoon.nix)
  "stats" # Menu-bar system monitor (network up/down speed, CPU, RAM, ...)
  "macs-fan-control" # Monitor / override fan speeds and temperature sensors
  "mac-mouse-fix" # Gestures + smooth scrolling for 3rd-party mice
  "betterdisplay" # Display management: virtual/HiDPI resolutions, brightness, PiP
]
