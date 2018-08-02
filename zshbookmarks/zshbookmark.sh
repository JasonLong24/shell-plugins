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
  echo ${ADD_DIR}
  echo ${ADD_ALIAS}
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
    -h|--help)
      help
      exit 0 ;;
    *)    
      POSITIONAL+=("$1") 
      shift ;;
  esac
done
set -- "${POSITIONAL[@]}" 
if [[ $EXEC_CONFIG = true ]]; then config; fi
if [[ $EXEC_ADD = true ]]; then add; fi
