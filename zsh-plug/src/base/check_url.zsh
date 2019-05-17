function base::check_url::isURL() {
  if echo $1 | grep 'https://\|http://\|git://' &>/dev/null; then
    return 0
  else
    return 1
  fi
}

function base::check_url::isPingable() {
  if ping -c 1 $1 &> /dev/null; then
    return 1
  else
    return 0
  fi
}
