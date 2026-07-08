{ ... }:

{
  programs.ssh = {
    enable = true;
    # デフォルト値に頼らず明示的に設定する
    enableDefaultConfig = false;

    # OrbStackのLinux VM/コンテナへ `ssh orb` で接続するため
    # （Hostブロックより前にincludeされる必要がある）
    includes = [ "~/.orbstack/ssh/config" ];

    settings."*" = {
      # 初回使用時に鍵をssh-agentへ自動追加
      AddKeysToAgent = "yes";
      # 接続維持（60秒ごとにkeepalive）
      ServerAliveInterval = 60;
      # パスフレーズをmacOSキーチェーンに保存
      UseKeychain = "yes";
    };
  };
}
