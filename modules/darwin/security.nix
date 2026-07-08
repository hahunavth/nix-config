{ ... }:

{
  # sudoのパスワード入力をTouch IDで代替する（/etc/pam.d/sudo_localに書き込まれる）
  security.pam.services.sudo_local.touchIdAuth = true;
}
