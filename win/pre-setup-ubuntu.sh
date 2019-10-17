#!/usr/bin/env bash
set -eux -o pipefail

USER_NAME=$1

# ユーザー作成
pass=$(openssl passwd -1 $USER_NAME)
useradd $USER_NAME -p $pass -m -s /bin/bash -G sudo

# sudo時にパスワードを要求しないようにする
echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-nopasswd
chmod 440 /etc/sudoers.d/10-nopasswd

# 日本のaptミラーサーバを使うようにする
sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list

# Ansibleのインストール
apt update
apt install -y software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt update
apt install -y ansible
apt install -y python-pip
pip install pywinrm
