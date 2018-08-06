#!/usr/bin/env bash

BM_PATH="$HOME/.dirbookmarks"
EXEC_ADD=false
EXEC_REMOVE=false
EXEC_CONFIG=false
EXEC_LIST=false
EXEC_EDIT=false

function config() {
  if [[ -d ${CONFIG} ]] || [[ $(echo ${CONFIG} | grep -o .dirbookmarks) = "" ]]; then
    echo Please Specify a .dirbookmarks file.
    return 1
  else
    BM_PATH="${CONFIG}"
  fi
}

function add() {
  if [[ -d ${ADD_DIR} ]]; then
    if [[ $(cat $BM_PATH | grep -w -o "${ADD_ALIAS}") = ${ADD_ALIAS} ]]; then
      echo ${ADD_ALIAS} is already bound.
      return 1
    else
      echo ${ADD_ALIAS} ${ADD_DIR} >> $BM_PATH
    fi
  else
    echo ${ADD_DIR} is not a directory.
    return 1
  fi
}

function remove() {
  if [[ $(cat $BM_PATH | grep -w -o "${REMOVE}") = "" ]]; then
    echo ${REMOVE} is not bound.
    return 1
  else
    removeline=$(cat $BM_PATH | grep -w -n "${REMOVE}" | cut -d : -f 1)
    read "?This will remove ($(cat $BM_PATH | awk NR==$removeline | sed -e 's/ / -> /g')) from your alias list. Are you sure? (y/n) "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sed -i "$removeline d" $BM_PATH
    else
      return 1
    fi
  fi
}

function edit() {
  if [[ $(cat $BM_PATH | grep -w -o "${EDIT}") = "" ]]; then
    echo ${EDIT} is not bound.
    return 1
  else
    vi +$(cat $BM_PATH | grep -w -n "${EDIT}" | cut -d : -f 1) $BM_PATH
  fi
}

function list() {
  echo -e Your current aliases:"\n"
  cat $BM_PATH | sed -e 's/ / -> /g'
  return 0
}

function bookmark() {
  if [[ $EXEC_ADD = false ]] && [[ $EXEC_REMOVE = false ]] && [[ $EXEC_LIST = false ]] && [[ $EXEC_EDIT = false ]]; then
    BOOKMARK_NAME=$(echo ${BOOKMARK} | cut -d : -f1)
    if [[ $(cat ${CONFIG} | grep -w -o "${BOOKMARK_NAME}") = "" ]]; then
      echo ${BOOKMARK_NAME} is not bound. Try using --add.
      return 1
    else
      BOOKMARK_EXTRA=$(echo ${BOOKMARK} | awk -F":" '{print $2}')
      BOOKMARK_LINE=$(cat $BM_PATH | awk NR==$(cat $BM_PATH | grep -w -n "${BOOKMARK_NAME}" | awk -F":" '{print $1}')'{print $2}')
      BOOKMARK_FULL=$(echo $BOOKMARK_LINE"/"$BOOKMARK_EXTRA)
      if [[ -f $BOOKMARK_FULL ]]; then
        BOOKMARK_FILE=$(echo $BOOKMARK_EXTRA | cut -d . -f2)
        isConfig
      elif [[ -d $BOOKMARK_FULL ]]; then
        source $BM_CONFIG
        cd $BOOKMARK_FULL 
        if [[ $BM_LS = true ]]; then
          ls
        fi
      else
        echo No such file or directory. $BOOKMARK_FULL 
        return 1
      fi
    fi
  fi
}

function bookmarkFile() {
  case $BOOKMARK_FILE in
    pdf|djvu) $BM_OPEN_PDF $BOOKMARK_FULL ;;
    html) $BM_OPEN_HTML $BOOKMARK_FULL ;;
    mp3|ogg|wav) $BM_OPEN_AUDIO $BOOKMARK_FULL ;;
    sc|csv|sxc|xlsx) $BM_OPEN_CSV $BOOKMARK_FULL ;;
    avi|mp4) $BM_OPEN_VIDEO $BOOKMARK_FULL ;;
    *) $BM_OPEN_TEXT $BOOKMARK_FULL ;;
  esac
}

function isConfig() {
  if [[ $BM_CONFIG = "" ]]; then
    echo Please give the path to your BM_CONFIG in your zshrc/bashrc file.
    return 1
  else
    source $BM_CONFIG 
    bookmarkFile
  fi
}

function help() {
  echo -e 'zsh Bookmarks\nNOTE replace cdbm with the name of your alias\n'
  echo -e 'Usage: cdbm [OPTIONS]... PATH\n'
  echo -e 'Options:
  -c, --config [FILE]         Path to your .dirbookmarks file. Default ~/.dirbookmarks
  -a, --add [PATH] [ALIAS]    Add a new directory alias.
  -r, --remove [ALIAS|PATH]   Remove an alias with the alias name or path.
  -l, --list                  List your current aliases.
  -h, --help                  Show this screen.\n'
  echo -e 'Examples:
  cdbm -a ~/Documents docs
  cdbm docs
  cdbm docs:[CHILD]
  cdbm -r docs'
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    -c|--config)
      if [[ $2 = "" ]] || [[ $2 =~ ^- ]]; then
        echo Config takes one argument. See --help
        return 1
      else
        CONFIG="$2"
        shift
        shift 
        EXEC_CONFIG=true
      fi ;;
    -a|--add)
      if [[ $2 = "" ]] || [[ $2 =~ ^- ]] || [[ $3 = "" ]] || [[ $3 =~ ^- ]]; then
        echo Add takes two arguments. See --help
        return 1
      else
        ADD_DIR="$2"
        ADD_ALIAS="$3"
        shift
        shift
        EXEC_ADD=true
      fi ;;
    -r|--remove)
      if [[ $2 = "" ]] || [[ $2 =~ ^- ]]; then
        echo Remove takes one arguments. See --help
        return 1
      else
        REMOVE="$2"
        shift
        shift
        EXEC_REMOVE=true
      fi ;;
    -e|--edit)
      if [[ $2 = "" ]] || [[ $2 =~ ^- ]]; then
        echo Edit takes one arguments. See --help
        return 1
      else
        EDIT="$2"
        shift
        shift
        EXEC_EDIT=true
      fi ;;
    -l|--list)
      EXEC_LIST=true 
      shift ;;
    -h|--help)
      help
      return 0 ;;
    *)    
      POSITIONAL+=("$1") 
      BOOKMARK="$1"
      EXEC_BOOKMARK=true
      shift ;;
  esac
done
set -- "${POSITIONAL[@]}" 
if [[ ! -e $BM_PATH ]]; then touch .dirbookmarks; fi
if [[ $EXEC_CONFIG = true ]]; then config; fi
if [[ $EXEC_ADD = true ]] && [[ $EXEC_REMOVE = true ]]; then echo You cannot remove and add in one statement. See --help; return 1; fi
if [[ $EXEC_ADD = true ]]; then add; fi
if [[ $EXEC_REMOVE = true ]]; then remove; fi
if [[ $EXEC_LIST = true ]]; then list; fi
if [[ $EXEC_EDIT = true ]]; then edit; fi
if [[ $EXEC_BOOKMARK = true ]]; then bookmark; fi
