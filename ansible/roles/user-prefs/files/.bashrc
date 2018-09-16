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
    echo -e " (\e[32m$branch\e[m)"
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

export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_HOME=$HOME/Android/Sdk
export NDK_ROOT=$ANDROID_SDK_ROOT/ndk-bundle
export PATH=$PATH:$ANDROID_HOME/tools

if which yarn >/dev/null; then
  export PATH=$PATH:$(yarn global bin)
fi
