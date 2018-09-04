#!/usr/bin/env bash
set -eux -o pipefail
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
source $SCRIPT_DIR/../common.sh

check_sudoed

function main () {
  $SCRIPT_DIR/../install-ansible.sh
  pacman -S --needed --noconfirm noto-fonts-cjk
  # 180820:
  # antergosをインストールしたあと
  # Notoフォントが入っていなかったので日本語を表示できなかった
  pause
}

main
