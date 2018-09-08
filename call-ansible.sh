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

pushd $SCRIPT_DIR/ansible >/dev/null
trap 'popd >/dev/null' EXIT

ANSIBLE_PB="env ANSIBLE_LOG_PATH=$PWD/ansible.log ansible-playbook -v -i hosts.yml -c local"

ANSIBLE_BECOME_FLAG=''
if [ "Linux" = "$(uname -s)" ]; then
  ANSIBLE_BECOME_FLAG=-b
fi

$ANSIBLE_PB $ANSIBLE_BECOME_FLAG setup.yml -e ansible_sudo_pass=$ANSIBLE_SUDO_PASS
$ANSIBLE_PB user-prefs.yml

pause
