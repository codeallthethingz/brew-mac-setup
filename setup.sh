#!/bin/bash

brewCasks="brave-browser 1password iterm2 slack expressvpn 
           visual-studio-code steam vlc qbittorrent zoom 
           goland ngrok docker dbeaver-community warp istats-menu 
           bartender adobe-acrobat-reader google-chrome iina 
           monitorcontrol xmind discord"

brews="go git bat zsh z vim wget curl htop pipenv gcc tree 
       jq postgresql coreutils r rsync tmux maven watch 
       gdrive goreleaser pandoc rename hub sqlite 
       mysql-client openjdk@8 python thefuck vim"

npmGlobals="vercel http-server npm-check-updates"

# don't check home brew for updates
HOMEBREW_NO_AUTO_UPDATE=1

# ask for sudo up front so we don't need to ask for passwords later
sudo -v

main() {
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
              if [ ! $failed ]; then 
                     echo failed
                     echo $failed
                     echo $output
                     exit 1
              fi
              echo "source ~/.zshrc-ext" >>~/.zshrc
              chsh -s /usr/local/bin/zsh
              echo "plugins=(git colored-man colorize pip python brew osx zsh-syntax-highlighting)" >~/.zshrc-ext
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
       for i in ${npmGlobals[@]}; do
              echo -n "installing $i... "
              npm list -g $i >/dev/null 2>&1
              contains=$?
              if [ $contains -ne 0 ]; then
                     echo -n "downloading... "
                     output=$(npm install -g $i 2>&1)
                     failed=$?
                     if [ $failed -ne 0 ]; then
                            echo -n "$output"
                            exit 1
                     fi
              fi
              echo "done"
       done
}
setupGo() {
       # Go paths
       echo 'export GOPATH="${HOME}/.go"' >>~/.zshrc-ext
       echo 'export GOROOT="$(brew --prefix golang)/libexec"' >>~/.zshrc-ext
       echo 'export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"' >>~/.zshrc-ext
}

setupGit() {
       email=$(git config --global user.email)
       username=$(git config --global user.name)
       echo -n "setting up git... "
       if [ "$username" == "" ]; then
              echo ""
              echo "enter username:"
              read gitUsername
              git config --global user.name "$gitUsername"
       fi
       if [ "$email" == "" ]; then
              echo ""
              echo "enter email:"
              read email
              git config --global user.email "$email"
       fi

       git config --global pager.branch false

       if [ ! -f ~/.ssh/id_rsa ]; then
              echo ""
              echo "generating public private key pair with email $email"
              ssh-keygen -t rsa -b 4096 -C "$email" -q -N "" -f ~/.ssh/id_rsa
       fi

       echo "done"
}

setupBrews() {
       brews=("$@")
       echo "--- brew brews ---"
       installedBrews=$(brew list)

       for i in ${brews[@]}; do
              echo -n "installing $i... "
              containsElement $i ${installedBrews[@]}
              contains=$?
              if [ $contains -ne 0 ]; then
                     echo -n " downloading... "
                     output=$(brew install $i >/dev/null)
                     failed=$?
                     if [ $failed -ne 0 ]; then
                            echo -n "$output"
                            exit 1
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
              /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
       }
       brew tap homebrew/cask-drivers
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

       for i in ${brewCasks[@]}; do
              echo -n "installing $i... "
              containsElement $i ${installedBrews[@]}
              contains=$?
              if [ $contains -ne 0 ]; then
                     echo -n "downloading... "
                     output=$(brew install --cask $i >/dev/null)
                     failed=$?
                     if [ $failed -ne 0 ]; then
                            echo -n "$output"
                            exit 1
                     fi
              fi
              echo "done"
       done
}

main
