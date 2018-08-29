#!/usr/bin/env bash
set -eux -o pipefail
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
source $SCRIPT_DIR/common.sh

if [ -e .env ]; then
  source .env
else
  echo sudo 用のパスワードを入力してください
  read -s ANSIBLE_SUDO_PASS
  echo ANSIBLE_SUDO_PASS=$ANSIBLE_SUDO_PASS >> .env
fi

pushd $SCRIPT_DIR/../ansible >/dev/null
trap 'popd >/dev/null' EXIT

ANSIBLE_PB="env ANSIBLE_LOG_PATH=$PWD/ansible.log ansible-playbook -v -i hosts.yml"

date >> $SCRIPT_DIR/setup.log;
$ANSIBLE_PB arch-setup.yml -e ansible_sudo_pass=$ANSIBLE_SUDO_PASS

date >> $SCRIPT_DIR/user-prefs.log;
$ANSIBLE_PB arch-user-prefs.yml

echo_info Press enter to continue...
read
