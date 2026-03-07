#!/bin/bash

brewCasks="1password iterm2 slack brave-browser
           visual-studio-code steam vlc zoom
           docker docker-desktop dbeaver-community claude
           nikitabobko/tap/aerospace ngrok google-chrome whatsapp
           plex-media-server pop"

brews="go git gh bat zsh z vim wget curl htop pipenv gcc tree
       jq coreutils rsync tmux watch ffmpeg
       gdrive goreleaser rename sqlite
       fswatch oven-sh/bun/bun uv"

npmGlobals="vercel http-server npm-check-updates pnpm @anthropic-ai/claude-code"

# don't check home brew for updates
export HOMEBREW_NO_AUTO_UPDATE=1

# --- colors and formatting ---
bold='\033[1m'
dim='\033[2m'
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
blue='\033[34m'
reset='\033[0m'

spinner_pid=""
spinner_frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

start_spinner() {
       local msg="$1"
       tput civis # hide cursor
       (
              i=0
              while true; do
                     printf "\r  ${blue}%s${reset} %s" "${spinner_frames[$((i % ${#spinner_frames[@]}))]}" "$msg"
                     i=$((i + 1))
                     sleep 0.08
              done
       ) &
       spinner_pid=$!
}

stop_spinner() {
       if [ -n "$spinner_pid" ]; then
              kill "$spinner_pid" 2>/dev/null
              wait "$spinner_pid" 2>/dev/null
              spinner_pid=""
       fi
       printf "\r\033[2K" # clear the line
       tput cnorm         # show cursor
}

print_success() {
       printf "  ${green}✓${reset} %s\n" "$1"
}

print_skip() {
       printf "  ${dim}✓ %s (already installed)${reset}\n" "$1"
}

print_fail() {
       printf "  ${red}✗${reset} %s ${red}(failed)${reset}\n" "$1"
}

print_header() {
       echo ""
       printf "${bold}━━━ %s ━━━${reset}\n" "$1"
}

# run a command with spinner, redirect output to logfile
# on failure, print the log. on success, stay clean.
run_install() {
       local name="$1"
       local logfile
       logfile=$(mktemp)
       shift

       start_spinner "installing $name..."
       if "$@" > "$logfile" 2>&1; then
              stop_spinner
              print_success "$name"
       else
              stop_spinner
              print_fail "$name"
              printf "    ${dim}log: %s${reset}\n" "$logfile"
              sed 's/^/    /' "$logfile"
              return 1
       fi
       rm -f "$logfile"
}

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

       echo ""
       printf "  ${green}${bold}✔ Setup complete${reset}\n"
       echo ""
}

# ----------- functions -------------
containsElement() {
       local e match="$1"
       shift
       for e; do [[ "$e" == "$match" ]] && return 0; done
       return 1
}
setupOhMyZsh() {
       print_header "Oh My Zsh"
       if [ -d "$HOME/.oh-my-zsh" ]; then
              print_skip "oh-my-zsh"
              return
       fi

       run_install "oh-my-zsh" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
       echo "source ~/.zshrc-ext" >>~/.zshrc
       chsh -s "$(which zsh)"
       echo "plugins=(git colored-man colorize pip python brew macos zsh-syntax-highlighting)" >~/.zshrc-ext
       echo ". $(brew --prefix)/etc/profile.d/z.sh" >>~/.zshrc-ext
       echo "disable r functions" >>~/.zshrc-ext
}
setupNvm() {
       print_header "NVM & Node"
       if [ ! -d "$HOME/.nvm" ]; then
              NVM_DIR=""
              nvmLatest=$(curl -sL https://github.com/nvm-sh/nvm/releases/latest | egrep -so "[0-9]*\.[0-9]*\.[0-9]*" | head -n 1 | tr -s " ")
              nodeLatest=$(curl -sL https://github.com/nodejs/node/releases/latest | egrep -so "[0-9]*\.[0-9]*\.[0-9]*" | head -n 1 | tr -s " ")

              run_install "nvm v$nvmLatest" bash -c "curl -s -o- 'https://raw.githubusercontent.com/nvm-sh/nvm/v${nvmLatest}/install.sh' | bash"
              NVM_DIR="$HOME/.nvm"
              [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
              run_install "node v$nodeLatest" nvm install --no-progress $nodeLatest
       else
              print_skip "nvm"
       fi
       # ensure nvm/node/npm are in PATH for subsequent steps
       export NVM_DIR="$HOME/.nvm"
       [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}
setupNpmGlobals() {
       npmGlobals=("$@")
       print_header "NPM Globals"
       for i in "${npmGlobals[@]}"; do
              if npm list -g "$i" >/dev/null 2>&1; then
                     print_skip "$i"
              else
                     run_install "$i" npm install -g "$i"
              fi
       done
}
setupGo() {
       print_header "Go"
       if grep -q 'GOPATH' ~/.zshrc-ext 2>/dev/null; then
              print_skip "go paths"
              return
       fi
       echo 'export GOPATH="${HOME}/.go"' >>~/.zshrc-ext
       echo 'export GOROOT="$(brew --prefix golang)/libexec"' >>~/.zshrc-ext
       echo 'export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"' >>~/.zshrc-ext
       print_success "go paths"
}

promptGitInfo() {
       gitEmail=$(git config --global user.email)
       gitUsername=$(git config --global user.name)
       if [ "$gitUsername" == "" ]; then
              printf "  ${yellow}?${reset} Enter git username: "
              read gitUsername
       fi
       if [ "$gitEmail" == "" ]; then
              printf "  ${yellow}?${reset} Enter git email: "
              read gitEmail
       fi
}

setupGit() {
       print_header "Git"
       git config --global user.name "$gitUsername"
       git config --global user.email "$gitEmail"
       git config --global pager.branch false
       print_success "git config"

       if [ -f ~/.ssh/id_ed25519 ]; then
              print_skip "ssh key"
       else
              ssh-keygen -t ed25519 -C "$gitEmail" -q -N "" -f ~/.ssh/id_ed25519
              print_success "ssh key"
       fi
}

setupBrews() {
       brews=("$@")
       print_header "Brew Formulae"
       installedBrews=$(brew list)

       for i in "${brews[@]}"; do
              local short="${i##*/}"
              if containsElement "$short" ${installedBrews[@]}; then
                     print_skip "$short"
              else
                     run_install "$short" brew install "$i"
              fi
       done
}

setupBrew() {
       print_header "Homebrew"
       if command -v brew >/dev/null 2>&1; then
              print_skip "homebrew"
       else
              /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
       fi
       # ensure brew is in PATH (needed on Apple Silicon where brew is at /opt/homebrew)
       if [ -x /opt/homebrew/bin/brew ]; then
              eval "$(/opt/homebrew/bin/brew shellenv)"
       elif [ -x /usr/local/bin/brew ]; then
              eval "$(/usr/local/bin/brew shellenv)"
       fi
}

setupMacosDefaults() {
       print_header "macOS Defaults"
       defaults write -g InitialKeyRepeat -int 13 # normal minimum is 15 (225 ms)
       defaults write -g KeyRepeat -int 2         # normal minimum is 2 (30 ms)
       print_success "key repeat"
       defaults write com.apple.dock persistent-apps -array
       print_success "clean dock"
}

setupBrewCasks() {
       brewCasks=("$@")
       print_header "Brew Casks"
       installedBrews=$(brew list)

       for i in "${brewCasks[@]}"; do
              local short="${i##*/}"
              if containsElement "$short" ${installedBrews[@]}; then
                     print_skip "$short"
              else
                     run_install "$short" brew install --cask "$i"
              fi
       done
}

main
