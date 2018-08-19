#!/usr/bin/env bash
set -eux
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

pushd $SCRIPT_DIR/ansible
trap 'popd' EXIT

ansible-playbook -i arch-hosts.yml arch-setup.yml --ask-become-pass
ansible-playbook -i arch-hosts.yml arch-user-settings.yml

echo Press enter to continue...
read
