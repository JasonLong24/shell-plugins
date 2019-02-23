#!/usr/bin/env zsh

red="%{%F{red}%}"
green="%{%F{green}%}"
yellow="%{%F{yellow}%}"
blue="%{%F{blue}%}"
purple="%{%F{purple}%}"
cyan="%{%F{cyan}%}"
white="%{%F{white}%}"
reset="%{%F{white}%}"

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
    CHECK=$(echo "✔ ")
  fi
}

function git_branch() {
  if is_clean; then
    RET_COL=$green
  else
    RET_COL=$red
  fi

  if [[ $(git rev-parse --show-superproject-working-tree) = "" ]]; then
    get_clean
    echo ${RET_COL}$(git symbolic-ref --short HEAD 2>/dev/null)$(get_build)${reset}${CHECK}
  else
    get_clean
    echo ${RET_COL}$(git rev-parse @ | cut -c -7 2>/dev/null)$(get_build)${reset}${CHECK}
  fi
}

function git_branch_dots() {
  if is_clean; then
    RET_COL=$green
  else
    RET_COL=$red
  fi

  if [[ $(git rev-parse --show-superproject-working-tree) = "" ]]; then
    echo ${RET_COL}$(git symbolic-ref --short HEAD 2>/dev/null)${reset}
  else
    echo ${RET_COL}$(git rev-parse @ | cut -c -7 2>/dev/null)${reset}
  fi
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
    others) echo '${yellow}?${reset}' ;;
    deleted) echo '${red}✖ ${reset}' ;;
    unmerged) echo '${cyan}⥿ ${reset}' ;;
  esac
}

function get_dots() {
  case $1 in
    modified) echo '${green}🌑${reset}' ;;
    others) echo '${yellow}🌑${reset}' ;;
    unmerged) echo '${cyan}🌑${reset}' ;;
  esac
}

function git_status() {
  info=$(git ls-files --$1 --exclude-standard $git_toplevel 2>/dev/null | wc -l)
  if [[ $info = 0 || -z $info ]]; then echo ''; else
    echo $(get_symbol $1)$info
  fi
}

function git_status_dots() {
  info=$(git ls-files --$1 --exclude-standard $git_toplevel 2>/dev/null | wc -l)
  if [[ $info = 0 || -z $info ]]; then echo ''; else
    echo $(get_dots $1)
  fi
}

function git_staged() {
  stage=$(git diff --name-only --cached | wc -l)
  if [[ $stage = 0 || -z $stage ]]; then echo ''; else
    echo $yellow● ${reset}$stage
  fi
}

function git_staged_dot() {
  stage=$(git diff --name-only --cached | wc -l)
  if [[ $stage = 0 || -z $stage ]]; then echo ''; else
    echo $yellow🌑${reset}
  fi
}

function get_build() {
  buildfiles=$(find $git_toplevel -maxdepth 1 ! -name '*~' -type f -printf '%P\n')
  possfiles=("Dockerfile" "build.xml" "build.gradle" "CMake" "Makefile")
  for (( i=1;i<=${#possfiles[@]};i++ )); do
    buildfile=$(echo $buildfiles | grep ${possfiles[$i]})
    build_type
  done
}

function build_type() {
  case $buildfile in
    build.xml) echo "${white}[${RET_COL}ant${white}]" ;;
    build.gradle) echo "${white}[${RET_COL}gradle${white}]" ;;
    CMake) echo "${white}[${RET_COL}cmake${white}]" ;;
    Makefile) echo "${white}[${RET_COL}make${white}]" ;;
    Dockerfile) echo "${white}[${RET_COL}docker${white}]" ;;
  esac
}

function git_full_prompt() {
  git_toplevel=$(git rev-parse --show-toplevel 2>/dev/null)
  if is_repo; then
    echo "$(git_branch)$(git_status others)$(git_status modified)$(git_status deleted)$(git_status unmerged)$(git_staged)"
  else
    echo ""
  fi
}

function git_full_dot_prompt() {
  git_toplevel=$(git rev-parse --show-toplevel 2>/dev/null)
  if is_repo; then
    echo "[$(git_branch_dots)$(git_status_dots others)$(git_status_dots modified)$(git_status_dots deleted)$(git_status_dots unmerged)$(git_staged_dot)]"
  else
    echo ""
  fi
}
