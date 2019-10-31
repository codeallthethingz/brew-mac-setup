#!/bin/bash


brewCask=("google-chrome" "1password" "iterm2" "slack" "dbeaver-community" "expressvpn" "visual-studio-code" "intellij-idea-ce" "steam" "vlc" "qbittorrent" "zoomus" "goland" "ngrok" "spectacle" "steermouse" "adoptopenjdk/openjdk/adoptopenjdk8" "docker" "sonos" "use-engine")
brew=("git" "bat" "zsh" "z" "vim" "wget" "curl" "htop" "pipenv" "gcc" "tree" "jq" "postgres" "coreutils" "r" "rsync" "tmux" "maven" "watch" "gdrive" "go-task/tap/go-task" "goreleaser" "pandoc" "rename")
npmGlobals=("now" "marko-cli" "http-server" "lasso-cli" "npm-check-updates")

# Annoying macos stuff
echo -n "setting key repeat..."
defaults write -g InitialKeyRepeat -int 13 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 2 # normal minimum is 2 (30 ms)
echo "done"
echo -n "cleaning toolbar..."
defaults write com.apple.dock persistent-apps -array
echo "done"

# Install Brew
echo -n "installing brew..."
command -v brew >/dev/null 2>&1 || { echo >&2 "Installing Homebrew Now"; \
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; }
brew tap caskroom/drivers
echo "done"

for i in ${brewCask[@]}; do
  echo -n "installing $i..."
  brew cask list $i >/dev/null 2>&1 || brew cask install $i
  echo "done"
done

for i in ${brew[@]}; do
  echo -n "installing $i..."
  brew list $i >/dev/null 2>&1 || brew install $i
  echo "done"
done


# Oh My Zsh
echo -n "installing zsh / oh my zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" >/dev/null 2>&1
if grep -q "zshrc-ext" ~/.zshrc; then
  echo -n ""
else
  echo "source ~/.zshrc-ext" >> ~/.zshrc
  chsh -s /usr/local/bin/zsh
fi
echo "done"

echo "plugins=(git colored-man colorize pip python brew osx zsh-syntax-highlighting)" > ~/.zshrc-ext
echo ". `brew --prefix`/etc/profile.d/z.sh" >> ~/.zshrc-ext
echo "disable r functions" >> ~/.zshrc-ext

# Miro
echo -n "installing miro..."
mdfind "kMDItemKind == 'Application'" | grep Miro >/dev/null 2>&1
res=$?
if [ $res -ne 0 ]; then 
  wget -O /tmp/miro.dmg "https://desktop.realtimeboard.com/platforms/darwin/Miro%20-%20formerly%20RealtimeBoard.dmg"
  hdiutil mount /tmp/miro.dmg
  sudo cp -R "/Volumes/Miro - formerly RealtimeBoard/Miro - formerly RealtimeBoard.app" /Applications/Miro.app
  hdiutil unmount "/Volumes/Miro - formerly RealtimeBoard/"
fi
echo "done"


echo "setting up git"
echo "username:"
read gitUsername
echo "email:"
read gitEmail

git config --global user.email "$gitEmail"
git config --global user.name "$gitUsername"
git config --global pager.branch false

echo "configuring ssh"
ssh-keygen -t rsa -b 4096 -C "$gitEmail" -q -N "" -f ~/.ssh/id_rsa

# Node
echo "installing nvm..."
command -v nvm >/dev/null 2>&1
nvmExists=$?
if [ $nvmExists -ne 0 ]; then 
  NVM_DIR=""
  nvmLatest=$(curl https://github.com/nvm-sh/nvm/releases/latest | egrep -so "[0-9]*\.[0-9]*\.[0-9]*")
  nodeLatest=$(curl https://github.com/nodejs/node/releases/latest | egrep -so "[0-9]*\.[0-9]*\.[0-9]*")
  echo -n " nvm: $nvmLatest node: $nodeLatest"
  curl -s -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${nvmLatest}/install.sh" | bash
  NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
  nvm install $nodeLatest 
fi

for i in ${npmGlobals[@]}; do
  echo -n "installing $i..."
  npm install -g $i
  echo "done"
done

echo "done"

# Go paths
echo 'export GOPATH="${HOME}/.go"' >> ~/.zshrc-ext
echo 'export GOROOT="$(brew --prefix golang)/libexec"' >> ~/.zshrc-ext
echo 'export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"' >> ~/.zshrc-ext
