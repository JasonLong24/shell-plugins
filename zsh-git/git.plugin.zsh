#!/usr/bin/env zsh

red=$(tput setaf 1) 
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
purple=$(tput setaf 5)
cyan=$(tput setaf 6) 
white=$(tput setaf 7)
reset=$(tput sgr0)
git_toplevel=$(git rev-parse --show-toplevel)

function dot_git() {
  dot_git="$(git rev-parse --git-dir 2>/dev/null)"
  printf '%s' $dot_git
}

function is_repo() {
  if [[ -n "$(dot_git)" ]]; then
    return 0 
  else
    return 1 
  fi
}

function is_clean() {
  if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
    return 0
  else
    return 1
  fi
}

function get_clean() {
  if is_repo && is_clean; then
    CHECK=$(echo "|✔ ")
  fi
}

function git_branch() {
  if is_clean; then
    RET_COL=$green
  else
    RET_COL=$red
  fi
  get_clean && echo ${RET_COL}$(git symbolic-ref --short HEAD 2>/dev/null)${reset}${CHECK}
}

function git_behind_master() {
  behind=$(git rev-list --left-only --count master...HEAD 2>/dev/null)
  if [[ $behind = 0 || -z $behind ]]; then; echo ''; else
    echo $behind-
  fi
}

function git_ahead_master() {
  ahead=$(git rev-list --right-only --count master...HEAD 2>/dev/null)
  if [[ $ahead = 0 || -z $ahead ]]; then; echo ''; else
    echo $ahead+
  fi
}

function git_position() {
  echo $(git_ahead_master)$(git_behind_master)
}

function get_symbol() {
  case $1 in
    modified) echo '${green}➕${reset}' ;;
    others) echo '$(tput bold)${blue}?${reset}' ;;
    deleted) echo '${red}✖ ${reset}' ;;
    unmerged) echo '${cyan}⥿ ${reset}' ;;
  esac
}

function git_status() {
  info=$(git ls-files --$1 --exclude-standard $git_toplevel 2>/dev/null | wc -l)
  if [[ $info = 0 || -z $info ]]; then echo ''; else
    echo $(get_symbol $1)$info
  fi
}

function git_staged() {
  stage=$(git diff --name-only --cached | wc -l)
  if [[ $stage = 0 || -z $stage ]]; then echo ''; else
    echo $(tput setaf 11)● ${reset}$stage
  fi
}

function git_full_prompt() {
  if is_repo; then
    if is_clean; then; SEPERATOR=""; else; SEPERATOR="|"; fi
    echo "($(git_branch)$SEPERATOR$(git_status others)$(git_status modified)$(git_status deleted)$(git_status unmerged)$(git_staged))"
  else
    echo ""
  fi
}
