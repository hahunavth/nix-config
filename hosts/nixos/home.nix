# Layer 4 of 4 — the OrbStack dev VM's home config.
#
# One line, and that is the point: everything else this VM needs is already in
# the shared core, so the shell, git, editor and prompt match the Mac exactly.
# The Atlassian tooling is on because this is a work dev VM.
{ ... }:

{
  hn.atlassian.enable = true;
}
