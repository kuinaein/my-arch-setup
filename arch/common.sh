#!/usr/bin/env bash

function change_console_color () {
  echo -en '\033[0;33m'
}

function echo_info () {
  change_console_color
  trap "echo -en '\033[0m'" RETURN
  echo $*
}
