#! /bin/bash
npmGlobals=( "$@" )
for i in ${npmGlobals[@]}; do
  echo -n "installing $i... "
  npm list -g $i >/dev/null 2>&1 
  contains=$?
  if [ $contains -ne 0 ]; then
    echo -n "downloading... "
    output=$(npm install -g $i  2>&1 )
    failed=$?
    if [  $failed -ne 0 ]; then
      echo -n "$output" 
      exit 1
    fi
  fi
  echo "done"
done