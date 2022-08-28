#! /bin/bash
brewCasks=( "$@" )
echo "--- brew casks ---"
HOMEBREW_NO_AUTO_UPDATE=1 
installedBrews=$(brew list)

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

for i in ${brewCasks[@]}; do
  echo -n "installing $i... "
  containsElement $i ${installedBrews[@]}
  contains=$?
  if [ $contains -ne 0 ]; then
    echo -n "downloading... "
    output=$(brew install --cask $i >/dev/null)
    failed=$?
    if [  $failed -ne 0 ]; then
      echo -n "$output" 
      exit 1
    fi
  fi
  echo "done"
done