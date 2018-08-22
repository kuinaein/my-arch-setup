#!/usr/bin/env bash
set -eux
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
source $SCRIPT_DIR/common.sh

pushd $SCRIPT_DIR/ansible
trap 'popd' EXIT

# --ask-become-pass でパスワードを確認されるため、強調表示する
change_console_color
ansible-playbook -v -i arch-hosts.yml arch-setup.yml --ask-become-pass
ansible-playbook -v -i arch-hosts.yml arch-user-prefs.yml

echo_info Press enter to continue...
read
