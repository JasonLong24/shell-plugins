function functions::add::addRepo()
{
  # First check for plugs
  base::check_path::checkSetup
  local clone_prefix=("https://github.com" "https://gitlab.com")
  local clone_url=$1

  # Check what type of entry it is
  # Link or shorthand
  if base::check_url::isURL $clone_url; then
    local final_clone_url=$clone_url
  else
    for prefix in ${clone_prefix[@]}; do
      local prefix_url=$prefix/$clone_url
      if base::check_url::isPingable $prefix_url; then
        local final_clone_url=$prefix_url
        break
      fi
    done
  fi

  # Clone it if it doesn't exist
  local final_clone_path=$PLUG_PATH/$(echo ${final_clone_url##*/} 2>/dev/null)
  if ! base::check_path::checkDir $final_clone_path; then
    git clone $final_clone_url $final_clone_path
  fi

}
