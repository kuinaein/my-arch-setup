#!/usr/bin/env bash

AUR_DIR=/home/${SUDO_USER:-$USER}/tmp/aur

function change_console_color () {
  echo -en '\e[0;33m'
}

function echo_info () {
  change_console_color
  trap "echo -en '\e[0m'" RETURN
  echo $*
}

function pause () {
  echo_info Press Enter to continue...
  read
}

function check_sudoed () {
  if [ ! -v SUDO_USER ]; then
    echo_info You have to \'sudo\'! >&2
    return 1
  fi
}