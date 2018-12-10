#!/usr/bin/env bash

REPO_PATH="repos"
REPO_DIR=".git-repos"
repos_length=$(cat $REPO_PATH 2>/dev/null | wc -l)
repos_list=$(find .git-repos -maxdepth 1 -type d | tail -n +2)

EXEC_REPOS_PATH=false
EXEC_REPO=false
EXEC_INDEX=false
EXEC_STYLE=false
EXEC_GENALL=false

function checkRepos() {
  if [[ -d ${REPO_SET} ]] || [[ $(echo ${REPO_SET} | grep -o "repos") = "" ]]; then
    echo Please Specify a repos file.
    exit 1
  else
    echo Found ${REPO_SET}
    REPO_PATH="${REPO_SET}"
  fi
}

function genRepos() {
  for (( i=1;i<=$repos_length;i++ )); do
    repos=$(cat $REPO_PATH | awk NR==$i)
    echo  "-> Found" $repos
    mkdir -p  $REPO_DIR
    if [[ -d $REPO_DIR/$(basename $repos) ]]; then
      git -C $REPO_DIR/$(basename $repos) pull origin master
    else
      git clone $repos $REPO_DIR/$(basename $repos)
    fi
    echo $repos
    mkdir -p $(basename $repos | sed 's/\.git//') && cd $(basename $repos | sed 's/\.git//')
    # Generate Owner by commits
    echo $(git -C ../$REPO_DIR/$(basename $repos) shortlog -sn | awk 'NR==1 {print $2}') > "../$REPO_DIR/"$(basename $repos)"/.git/owner"
    # Set description to project mirror
    echo Mirror of $repos > "../$REPO_DIR/"$(basename $repos)"/.git/description"
    stagit -c .cache ../$REPO_DIR/$(basename $repos)
    cp ../style.css .
    cd ..
  done
}

function genCreds() {
  echo "a"
}

function genIndex() {
  echo Generating index
  stagit-index $(echo $repos_list) > index.html
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
  rm *.xml *.html 2>/dev/null
  rm -rf ./*/ 2>/dev/null
}

function genAll() {
  if [[ $EXEC_REPO = true ]] || [[ $EXEC_INDEX = true ]]; then
    echo "You cannot run -a with -r or -i. See --help" && exit 1
  else
    genClear
    genRepos
    genIndex
  fi
}

function help() {
  echo "Help Page"
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    -rp|--repos-path)
      if [[ $2 = "" ]] || [[ $2 =~ ^- ]]; then
        echo repos takes one argument. See --help
        exit 1
      else
        REPO_SET="$2"
      fi
      shift
      shift
      EXEC_REPOS_PATH=true
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
    -r|--repo)
      EXEC_REPO=true
      shift ;;
    -i|--index)
      EXEC_INDEX=true
      shift ;;
    -a|--all)
      EXEC_GENALL=true
      shift ;;
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

if [[ $EXEC_REPOS_PATH = true ]]; then checkRepos; fi
if [[ $EXEC_STYLE = true ]]; then genStyle; fi
if [[ $EXEC_GENALL = true ]]; then genAll; fi
if [[ $EXEC_REPO = true ]]; then genRepos; fi
if [[ $EXEC_INDEX = true ]]; then genIndex; fi
