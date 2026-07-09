{ ... }:

{
  # Use Touch ID instead of a typed password for sudo (written to /etc/pam.d/sudo_local)
  security.pam.services.sudo_local.touchIdAuth = true;
}
