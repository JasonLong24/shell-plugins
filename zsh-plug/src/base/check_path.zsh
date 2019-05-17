function base::check_path::checkFile() {
  if [[ -f $1 ]]; then
    return 1
  else
    return 0
  fi
}

function base::check_path::checkDir() {
  if [[ -d $1 ]]; then
    return 0
  else
    return 1
  fi
}

function base::check_path::checkSetup() {
  if ! base::check_path::checkDir; then
    mkdir -p $PLUG_PATH
  fi
}
