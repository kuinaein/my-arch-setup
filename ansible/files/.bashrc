#!/usr/bin/env bash
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
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

export BROWSER=/usr/bin/chromium
export EDITOR=/usr/bin/nvim
