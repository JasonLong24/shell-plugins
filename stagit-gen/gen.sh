#!/usr/bin/env bash

REPO_PATH="repos"
repos_length=$(cat $REPO_PATH | wc -l)
EXEC_REPOS=false
EXEC_STYLE=false

function checkRepos() {
  if [[ -d ${REPO_SET} ]] || [[ $(echo ${REPO_SET} | grep -o "repos") = "" ]]; then
    echo Please Specify a repos file.
    exit 1
  else
    REPO_PATH="${REPO_SET}"
  fi
}

function genRepos() {
  for (( i=1;i<=$repos_length;i++ )); do
    repos=$(cat $REPO_PATH | awk NR==$i)
    echo  "-> Found" $(basename $repos) 
    mkdir $(basename $repos) && cd $(basename $repos)
    stagit -c .cache $repos
    cp ../style.css .
    cd ..
  done
}

function genIndex() {
  stagit-index $(cat $REPO_PATH) > index.html
}

function genStyle() {
  if [ -f $STYLE_PATH ] && [[ $STYLE_PATH == *.css ]]; then
    cp $STYLE_PATH .
  else
    echo Please Specify a css file
  fi
}

function genClear() {
  echo Clearing directory
  rm *.html 2>/dev/null
  rm -rf ./*/ 2>/dev/null
}

function genAll() {
  genClear
  genIndex
  genRepos
}

function help() {
  echo "Help Page"
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    -r|--repos)
      if [[ $2 = "" ]] || [[ $2 =~ ^- ]]; then
        echo repos takes one argument. See --help
        exit 1
      else
        REPO_SET="$2"
      fi
      shift 
      shift
      EXEC_REPOS=true
      ;;
    -s|--style)
      if [[ $2 = "" ]] || [[ $2 =~ ^- ]]; then
        echo style takes one argument. See --help
        exit 1
      else
        STYLE_PATH="$2"
      fi
      shift 
      shift
      EXEC_STYLE=true
      ;;
    -c|--clear)
      genClear
      exit 0 ;;
    -h|--help) 
      help
      exit 0 ;;
    *)    
      POSITIONAL+=("$1") 
      shift 
      ;;
  esac
done
set -- "${POSITIONAL[@]}" 

if [[ $EXEC_REPOS = true ]]; then checkRepos; fi
if [[ $EXEC_STYLE = true ]]; then genStyle; fi
genAll
