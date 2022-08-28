#! /bin/bash
echo -n "installing nvm... "
if [ ! -d "$HOME/.nvm" ]; then 
  NVM_DIR=""
  nvmLatest=$(curl -sL https://github.com/nvm-sh/nvm/releases/latest | egrep -so "[0-9]*\.[0-9]*\.[0-9]*" | head -n 1 | tr -s " ")
  nodeLatest=$(curl -sL https://github.com/nodejs/node/releases/latest | egrep -so "[0-9]*\.[0-9]*\.[0-9]*" | head -n 1 | tr -s " ")
  echo -n " nvm: $nvmLatest node: $nodeLatest "
  curl -s -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${nvmLatest}/install.sh" | bash >/dev/null 2>&1
  NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
  nvm install --no-progress $nodeLatest >/dev/null 2>&1
fi
echo "done"