# 個人用の環境セットアップスクリプト

## 共通

1. `my-setup/../ansible/files`に以下のファイルを置く。
   - `id_rsa` 秘密鍵
   - `id_rsa.pub` 公開鍵

## Antergos

1. sudo arch/pre-setup.sh
1. 再ログインして文字化けを直す
1. すとれりちあ様の DB インスタンスを起動
1. call-ansible.sh
1. すとれりちあ様の DB インスタンスを停止
1. Chromium にログイン
1. Android Studio の SDK Manager で NDK を入れる

## Windows

1. 電源設定で高速スタートアップを無効化する
1. win/1st-setup.bat
1. 管理者権限で win/pre-setup.ps1
1. win/user-setup.ps1
1. win/call-ansible.ps1
1. Google Chrome にログイン

## Mac

1. mac/pre-setup.sh
1. call-ansible.sh
1. Chromium にログイン

## ライセンス

そんなものありません。

パブリックドメイン、CC0 と Unlicense のトリプルライセンスとします。

- Unlicense http://unlicense.org
- CC0 https://creativecommons.org/publicdomain/zero/1.0/deed.ja
