#!/usr/bin/env bash
set -eux -o pipefail
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
source $SCRIPT_DIR/common.sh

if [ ! -v SUDO_USER ]; then
  echo_info You have to \'sudo\'! >&2
  exit 1
fi

AUR_DIR=/home/$SUDO_USER/tmp/aur


function main () {
  pacman -Syy
  pacman -S --needed --noconfirm ansible git noto-fonts-cjk
  # 180820:
  # antergosをインストールしたあと
  # Notoフォントが入っていなかったので日本語を表示できなかった

  install_from_aur ansible-aur-git

  echo_info Press enter to continue...
  read
}

function install_from_aur () {
  local pkg=$1

  if pacman -Q $pkg; then
    return
  fi

  if [ ! -d "$AUR_DIR" ]; then
    sudo -u $SUDO_USER mkdir -p "$AUR_DIR"
  fi
  pushd "$AUR_DIR" >/dev/null
  trap "popd >/dev/null" RETURN

  if [ -d "$pkg" ]; then
    rm -rf "$pkg"
  fi

  sudo -u $SUDO_USER -H git clone https://aur.archlinux.org/$pkg.git
  cd $pkg
  sudo -u $SUDO_USER -H makepkg -si --needed --noconfirm
}

main
