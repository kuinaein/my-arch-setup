#!/usr/bin/env bash
set -eux -o pipefail
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

# 日本のpacmanミラーサーバを使うようにする
sed -i 's/^Server/#Server/' /etc/pacman.d/mirrorlist
sed -i '/## Japan/,/##/ s/^#Server/Server/' /etc/pacman.d/mirrorlist

pacman-key --init
pacman-key --populate
pacman -Syyu --noconfirm
