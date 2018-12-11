#!/usr/bin/env bash

if [ ! -f repos ]; then
  echo Cannot find repos file.
  exit 1
fi

REPO_PATH="repos"
REPO_DIR=".git-repos"
repos_length=$(cat $REPO_PATH 2>/dev/null | wc -l)

EXEC_REPOS_PATH=false
EXEC_REPO=false
EXEC_INDEX=false
EXEC_STYLE=false
EXEC_GENALL=false
EXEC_METADATA=false

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
    repos_local=$(echo $repos | cut -d ':' -f1)
    echo  "-> Found" $repos
    mkdir -p  $REPO_DIR
    if [[ -d $REPO_DIR/$(basename $repos) || -d $REPO_DIR/$repos_local ]]; then
      if echo $repos | grep '://' &>/dev/null; then
        git -C $REPO_DIR/$(basename $repos) pull origin master
        mkdir -p $(basename $repos | sed 's/\.git//') && cd $(basename $repos | sed 's/\.git//')
      else
        git -C $REPO_DIR/$repos_local pull origin master
        mkdir -p $repos_local && cd $repos_local
      fi
    else
      git clone $repos $REPO_DIR/$(basename $repos)
      mkdir -p $(basename $repos | sed 's/\.git//') && cd $(basename $repos | sed 's/\.git//')
    fi

    if echo $repos | grep '://' &>/dev/null; then
      echo -e "\n" && stagit -c .cache ../$REPO_DIR/$(basename $repos)
    else
      echo -e "\n" && stagit -c .cache ../$REPO_DIR/$repos_local
    fi

    cp ../style.css .
    cd ..
  done
}

function genCreds() {
  echo -e 'Generating metadata\n'
  for (( i=1;i<=$repos_length;i++ )); do
    repos=$(cat $REPO_PATH | awk NR==$i)
    repos_local=$(echo $repos | cut -d ':' -f1)
    echo -e '-> Found metadata for '$repos'\n'
    if echo $repos | grep '://' &>/dev/null; then
      if echo $repos | grep 'git://'&>/dev/null; then
        echo $(git -C $REPO_DIR/$(basename $repos) shortlog -sn | awk 'NR==1 {print $2}') > "$REPO_DIR/"$(basename $repos)"/.git/owner"
      else
        echo $(echo $repos | sed 's/\// /g' | awk '{print $3}') > "$REPO_DIR/"$(basename $repos)"/.git/owner"
      fi
      echo Mirror of $repos > "$REPO_DIR/"$(basename $repos)"/.git/description"
    else
      echo $(echo $repos | cut -d ':' -f2-) > "$REPO_DIR/$repos_local/.git/owner"
      echo Mirror of $repos > "$REPO_DIR/$repos_local/.git/description"
    fi

  done
}

function genIndex() {
  echo Generating index
  repos_list=$(find .git-repos -maxdepth 1 -type d | tail -n +2)
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
  echo -e 'Clearing directory\n'
  rm *.xml *.html 2>/dev/null
  rm -rf ./*/ 2>/dev/null
}

function genAll() {
  if [[ $EXEC_REPO = true ]] || [[ $EXEC_INDEX = true ]]; then
    echo "You cannot run -a with -r or -i. See --help" && exit 1
  else
    echo -e Compile: $(date +'%Y-%m-%d %H:%M:%S')'\n'
    genClear
    genRepos
    genIndex
  fi
}

function help() {
  echo -e 'stagit-gen\n'
  echo -e 'Usage: stagit-gen [OPTIONS]... PATH\n'
  echo -e 'Options:
  -rp, --repos-path [FILE]    Path to your repos file. Default ./repos
  -s, --style [FILE]          Path to stylesheet. Default ./style.css
  -r, --repo                  Generate static repos based on repos file
  -i, --index                 Generate index file based on repos file.
  -m, --metadata              Generate owner and description of repo.
  -a, --all                   Clear, generate repos and index.
  -c, --clear                 Clear current directory of all repos.
  -h, --help                  Show this screen'
  echo -e 'Examples:
  stagit-gen --all -s ~/style.css
  stagit-gen --index -rp ~/repos'
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
    -m|--metadata)
      EXEC_METADATA=true
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
if [[ $EXEC_METADATA = true ]]; then genCreds; fi
if [[ $EXEC_GENALL = true ]]; then genAll; fi
if [[ $EXEC_REPO = true ]]; then genRepos; fi
if [[ $EXEC_INDEX = true ]]; then genIndex; fi
