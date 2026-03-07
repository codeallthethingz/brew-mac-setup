#!/bin/bash

brewCasks="1password iterm2 slack brave-browser
           visual-studio-code steam vlc zoom
           docker docker-desktop dbeaver-community claude
           aerospace ngrok google-chrome whatsapp
           plex-media-server pop"

brews="go git gh bat zsh z vim wget curl htop pipenv gcc tree
       jq coreutils rsync tmux watch ffmpeg
       gdrive goreleaser rename sqlite
       fswatch bun uv"

npmGlobals="vercel http-server npm-check-updates pnpm @anthropic-ai/claude-code"

# don't check home brew for updates
export HOMEBREW_NO_AUTO_UPDATE=1

# ask for sudo up front so we don't need to ask for passwords later
sudo -v
# keep sudo alive in the background
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

main() {
       promptGitInfo
       setupMacosDefaults
       setupBrew
       setupBrewCasks $brewCasks
       setupBrews $brews
       setupGit
       setupNvm
       setupNpmGlobals $npmGlobals
       setupGo
       setupOhMyZsh
       echo "complete"
}

# ----------- functions -------------
containsElement() {
       local e match="$1"
       shift
       for e; do [[ "$e" == "$match" ]] && return 0; done
       return 1
}
setupOhMyZsh() {
       # # Oh My Zsh
       echo -n "installing oh my zsh... "
       if [ ! -d "$HOME/.oh-my-zsh" ]; then
              echo -n " downloading... "

              output=$(sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>&1)
              failed=$?
              if [ $failed -ne 0 ]; then
                     echo "failed"
                     echo "$output"
              fi
              echo "source ~/.zshrc-ext" >>~/.zshrc
              chsh -s "$(which zsh)"
              echo "plugins=(git colored-man colorize pip python brew macos zsh-syntax-highlighting)" >~/.zshrc-ext
              echo ". $(brew --prefix)/etc/profile.d/z.sh" >>~/.zshrc-ext
              echo "disable r functions" >>~/.zshrc-ext
       fi

       echo "done"
}
setupNvm() {
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
}
setupNpmGlobals() {
       npmGlobals=("$@")
       for i in "${npmGlobals[@]}"; do
              echo -n "installing $i... "
              if ! npm list -g "$i" >/dev/null 2>&1; then
                     echo -n "downloading... "
                     output=$(npm install -g "$i" 2>&1)
                     failed=$?
                     if [ $failed -ne 0 ]; then
                            echo "$output"
                     fi
              fi
              echo "done"
       done
}
setupGo() {
       # Go paths
       echo -n "setting up go paths... "
       if ! grep -q 'GOPATH' ~/.zshrc-ext 2>/dev/null; then
              echo 'export GOPATH="${HOME}/.go"' >>~/.zshrc-ext
              echo 'export GOROOT="$(brew --prefix golang)/libexec"' >>~/.zshrc-ext
              echo 'export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"' >>~/.zshrc-ext
       fi
       echo "done"
}

promptGitInfo() {
       gitEmail=$(git config --global user.email)
       gitUsername=$(git config --global user.name)
       if [ "$gitUsername" == "" ]; then
              echo "enter git username:"
              read gitUsername
       fi
       if [ "$gitEmail" == "" ]; then
              echo "enter git email:"
              read gitEmail
       fi
}

setupGit() {
       echo -n "setting up git... "
       git config --global user.name "$gitUsername"
       git config --global user.email "$gitEmail"
       git config --global pager.branch false

       if [ ! -f ~/.ssh/id_ed25519 ]; then
              echo "generating public private key pair with email $gitEmail"
              ssh-keygen -t ed25519 -C "$gitEmail" -q -N "" -f ~/.ssh/id_ed25519
       fi

       echo "done"
}

setupBrews() {
       brews=("$@")
       echo "--- brew brews ---"
       installedBrews=$(brew list)

       for i in "${brews[@]}"; do
              echo -n "installing $i... "
              if ! containsElement "$i" ${installedBrews[@]}; then
                     echo -n " downloading... "
                     output=$(brew install "$i" 2>&1)
                     failed=$?
                     if [ $failed -ne 0 ]; then
                            echo "$output"
                     fi
              fi
              echo "done"
       done

}

setupBrew() {
       # Install Brew
       echo -n "installing brew... "
       command -v brew >/dev/null 2>&1 || {
              echo >&2 "Installing Homebrew Now"
              /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
       }
       # ensure brew is in PATH (needed on Apple Silicon where brew is at /opt/homebrew)
       if [ -x /opt/homebrew/bin/brew ]; then
              eval "$(/opt/homebrew/bin/brew shellenv)"
       elif [ -x /usr/local/bin/brew ]; then
              eval "$(/usr/local/bin/brew shellenv)"
       fi
       echo "done"
}

setupMacosDefaults() {
       # Annoying macos stuff
       echo -n "setting key repeat... "
       defaults write -g InitialKeyRepeat -int 13 # normal minimum is 15 (225 ms)
       defaults write -g KeyRepeat -int 2         # normal minimum is 2 (30 ms)
       echo "done"
       echo -n "cleaning toolbar... "
       defaults write com.apple.dock persistent-apps -array
       echo "done"
}

setupBrewCasks() {
       brewCasks=("$@")
       echo "--- brew casks ---"
       installedBrews=$(brew list)

       for i in "${brewCasks[@]}"; do
              echo -n "installing $i... "
              if ! containsElement "$i" ${installedBrews[@]}; then
                     echo -n "downloading... "
                     output=$(brew install --cask "$i" 2>&1)
                     failed=$?
                     if [ $failed -ne 0 ]; then
                            echo "$output"
                     fi
              fi
              echo "done"
       done
}

main
