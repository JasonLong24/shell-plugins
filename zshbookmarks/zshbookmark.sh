#!/usr/bin/env bash

BM_PATH="$HOME/.dirbookmarks"

function config() {
  if [[ -d ${CONFIG} ]] || [[ $(echo ${CONFIG} | grep -o .dirbookmarks) = "" ]]; then
    echo Please Specify a .dirbookmarks file.
    exit 1
  else
    BM_PATH="${CONFIG}"
  fi
}

function add() {
  if [[ -d ${ADD_DIR} ]]; then
    if [[ $(cat $BM_PATH | grep -w -o "${ADD_ALIAS}") = ${ADD_ALIAS} ]]; then
      echo ${ADD_ALIAS} is already bound.
      exit 1
    else
      echo ${ADD_ALIAS} ${ADD_DIR} >> $BM_PATH
    fi
  else
    echo ${ADD_DIR} is not a directory.
    exit 1
  fi
}

function remove() {
  if [[ $(cat $BM_PATH | grep -w -o "${REMOVE}") = "" ]]; then
    echo ${REMOVE} is not bound.
    exit 1
  else
    removeline=$(cat $BM_PATH | grep -w -n "${REMOVE}" | cut -d : -f 1)
    read -p "This will remove ($(cat $BM_PATH | awk NR==$removeline | sed -e 's/ / -> /g')) from your alias list. Are you sure? (y/n) " -n 1;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sed -i "$removeline d" $BM_PATH
    else
      exit 1
    fi
  fi
}

function list() {
  echo -e Your current aliases:"\n"
  cat $BM_PATH | sed -e 's/ / -> /g'
  exit 0
}

function help() {
  echo "HELP"
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    -c|--config)
      if [[ $2 = "" ]] || [[ $3 =~ ^- ]]; then
        echo Config takes one argument. See --help
        exit 1
      else
        CONFIG="$2"
        shift
        shift 
        EXEC_CONFIG=true
      fi ;;
    -a|--add)
      if [[ $2 = "" ]] || [[ $2 =~ ^- ]] || [[ $3 = "" ]] || [[ $3 =~ ^- ]]; then
        echo Add takes two arguments. See --help
        exit 1
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
        exit 1
      else
        REMOVE="$2"
        shift
        shift
        EXEC_REMOVE=true
      fi ;;
    -l|--list)
      EXEC_LIST=true 
      shift
      shift ;;
    -h|--help)
      help
      exit 0 ;;
    *)    
      POSITIONAL+=("$1") 
      shift ;;
  esac
done
set -- "${POSITIONAL[@]}" 
if [[ ! -e $BM_PATH ]]; then touch .dirbookmarks; fi
if [[ $EXEC_CONFIG = true ]]; then config; fi
if [[ $EXEC_ADD = true ]] && [[ $EXEC_REMOVE = true ]]; then echo You cannot remove and add in one statement. See --help; exit 1; fi
if [[ $EXEC_ADD = true ]]; then add; fi
if [[ $EXEC_REMOVE = true ]]; then remove; fi
if [[ $EXEC_LIST = true ]]; then list; fi

if [[ $# = 0 ]]; then
  echo command goes here
fi
