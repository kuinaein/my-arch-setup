#!/usr/bin/env bash
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [ "Darwin" = "$(uname -s)"  ]; then
  LSFLAGS='-G'
else
  LSFLAGS='--color=auto'
fi
alias ls="ls $LSFLAGS"

alias grep='grep --color=auto'

function parse_git_branch() {
  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
  if [ "" != "$branch" ]; then
    echo $' (\e[32m'$branch$'\e[m)'
  fi
}

PS1='[\u@\h \w$(parse_git_branch)]\$ '

if [ -e ~/.bashrc.aliases ] ; then
  source ~/.bashrc.aliases
fi

if [ "Darwin" != "$(uname -s)"  ]; then
  export BROWSER=/usr/bin/chromium
  export EDITOR=/usr/bin/nvim
fi

if [ "Darwin" = "$(uname -s)"  ]; then
  export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
else
  export ANDROID_SDK_ROOT=$HOME/Android/Sdk
fi
export ANDROID_HOME=$ANDROID_SDK_ROOT
export NDK_ROOT=$ANDROID_SDK_ROOT/ndk-bundle
export PATH=$PATH:$ANDROID_HOME/tools

if [ "" = "${COCOS_X_ROOT:-}" ]; then
  export COCOS_X_ROOT=$HOME/bin/cocos2d-x/current
  export COCOS_CONSOLE_ROOT=$COCOS_X_ROOT/tools/cocos2d-console/bin
  export COCOS_TEMPLATES_ROOT=$COCOS_X_ROOT/templates
  export PATH=$PATH:$COCOS_X_ROOT:$COCOS_CONSOLE_ROOT:$COCOS_TEMPLATES_ROOT
fi

if which yarn >/dev/null; then
  export PATH=$PATH:$(yarn global bin)
fi
