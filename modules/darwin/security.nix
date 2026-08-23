# Authentication policy for this Mac.
{ ... }:

{
  # Use Touch ID instead of a typed password for sudo (written to /etc/pam.d/sudo_local).
  # Only takes effect from the SECOND switch on: the first switch is what creates
  # /etc/pam.d/sudo_local, and the sudo running that switch already read the old
  # stack. Expect to type your password once more.
  security.pam.services.sudo_local.touchIdAuth = true;
}
