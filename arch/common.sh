#!/usr/bin/env bash

function change_console_color () {
  echo -en '\e[0;33m'
}

function echo_info () {
  change_console_color
  trap "echo -en '\e[0m'" RETURN
  echo $*
}
