#!/usr/bin/env bash
set -eux
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
AUR_DIR=/home/$SUDO_USER/tmp/aur

pacman -Sy --needed --noconfirm ansible git noto-fonts-cjk
#  180820
# antergosをインストールしたあと
# Notoフォントが入っていなかったので日本語を表示できなかった

if [ ! -d "$AUR_DIR" ]; then
  sudo -u $SUDO_USER mkdir -p "$AUR_DIR"
fi
pushd "$AUR_DIR"
trap "popd" EXIT
sudo -u $SUDO_USER -H git clone https://aur.archlinux.org/ansible-aur-git.git
cd ansible-aur-git
sudo -u $SUDO_USER -H makepkg -si --needed --noconfirm

echo Press enter to continue...
read

