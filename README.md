# 個人用の環境セットアップスクリプト

## Windows

1. `win/1st-setup.bat`
1. 管理者権限で `win/pre-setup.ps1`
1. 再起動
1. `win/user-setup.ps1`
    - 2019-10-13現在、libsslの更新等でプロンプトが出るが全てyesでOK
1. `ansible/hosts.example.yml` をコピーして適切に書き換える
1. `win/call-ansible.ps1 -Host [hosts.ymlのパス]]`
1. 管理者権限で`win/remove-features.ps1`

## ライセンス

そんなものありません。

パブリックドメイン、CC0 と Unlicense のトリプルライセンスとします。

- Unlicense http://unlicense.org
- CC0 https://creativecommons.org/publicdomain/zero/1.0/deed.ja
