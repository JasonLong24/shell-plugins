function zsh-plug()
{
  base::check_path::checkSetup
  # local clone_url=$1
  # if isUrl $clone_url; then
  #   local clone_url_expanded=$DEFAULT_URL/$clone_url
  #   if isCloned $(echo "${clone_url_expanded##*/}"); then
  #     echo "-> Found $(echo ${clone_url_expanded##*/})"
  #   else
  #     git clone $clone_url_expanded $PLUG_PATH/$(echo ${clone_url_expanded##*/})
  #   fi
  # else
  #   if isCloned $(echo "${clone_url##*/}"); then
  #     echo "-> Found $(echo ${clone_url##*/})"
  #   else
  #     git clone $clone_url $PLUG_PATH/$(echo ${clone_url##*/})
  #   fi
  # fi
}
