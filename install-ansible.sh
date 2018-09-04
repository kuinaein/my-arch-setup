#!/usr/bin/env bash
set -eux -o pipefail
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
source $SCRIPT_DIR/common.sh

function main (){
  check_sudoed
  pacman -Syy
  pacman -S --needed --noconfirm ansible git binutils
  # 180904 ArchWSLにはbin-utilsが入ってない
  install_from_aur ansible-aur-git
  # 静的にパースされるYAMLに含まれているモジュールは全て入れる必要がある
  # でないとパースエラーになる
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
