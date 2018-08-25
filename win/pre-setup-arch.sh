#!/usr/bin/env bash
set -eux -o pipefail
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

USER_NAME=$1
# 日本のpacmanミラーサーバを使うようにする
sed -i 's/^Server/#Server/' /etc/pacman.d/mirrorlist
sed -i '/## Japan/,/##/ s/^#Server/Server/' /etc/pacman.d/mirrorlist

pacman-key --init
pacman-key --populate
pacman -Syyu --noconfirm

pass=$(openssl passwd -1 $USER_NAME)
useradd $USER_NAME -p $pass -m -s /bin/bash -G wheel
# sudo時にパスワードを要求しないようにする
echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-nopasswd
chmod 440 /etc/sudoers.d/10-nopasswd
