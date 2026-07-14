# socat port forwards to the Windows machine (Tailscale IP). Bind to localhost.
#   win-on     start the usual set (local 5005->5005, 7130, 6090, 9220)
#   win-5006   switch local 5005 to forward to remote 5006 instead
#   win-5005   switch local 5005 back to remote 5005
#   win-off    stop all forwards        win-status   show what's running
{ lib, ... }:
let
  winHost = "100.110.190.53";
  # build a backgrounded socat forward: local port -> winHost:remote port
  fwd =
    local: remote:
    "nohup socat TCP-LISTEN:${local},fork,reuseaddr,bind=127.0.0.1 TCP:${winHost}:${remote} >/dev/null 2>&1 &";
  # kill any existing socat listener on a given local port
  killPort = port: "pkill -f 'TCP-LISTEN:${port},'";
  kill5005 = killPort "5005";
  kill5006 = killPort "5006";
  kill6090 = killPort "6090";
  kill7129 = killPort "7129";
  kill7130 = killPort "7130";
  kill9220 = killPort "9220";
in
{
  win-on = lib.concatStringsSep " " [
    (fwd "5005" "5005")
    (fwd "7130" "7130")
    (fwd "6090" "6090")
    (fwd "9220" "9220")
  ];
  win-5005 = "${kill5005}; ${fwd "5005" "5005"}";
  win-5006 = "${kill5006}; ${fwd "5005" "5006"}";
  win-6090 = "${kill6090}; ${fwd "6090" "6090"}";
  win-7129 = "${kill7129}; ${fwd "7129" "7129"}";
  win-7130 = "${kill7130}; ${fwd "7130" "7130"}";
  win-9220 = "${kill9220}; ${fwd "9220" "9220"}";
  win-off = "pkill -f 'TCP:${winHost}:'";
  win-status = "pgrep -fl 'TCP:${winHost}:' || echo 'no forwards running'";
}
