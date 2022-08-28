#!/bin/bash

brewCasks="brave-browser 1password iterm2 slack expressvpn 
           visual-studio-code steam vlc qbittorrent zoom 
           goland ngrok docker dbeaver-community"

brews="go git bat zsh z vim wget curl htop pipenv gcc tree 
       jq postgresql coreutils r rsync tmux maven watch 
       gdrive go-task goreleaser pandoc rename 
       hub sqlite mysql-client openjdk@8"

npmGlobals="vercel http-server npm-check-updates"

# exit if anything fails
set -e

# ask for sudo up front so we don't need to ask for passwords later
sudo -v

./scriptlets/setup-macos-defaults.sh
./scriptlets/setup-brew.sh
./scriptlets/setup-brew-casks.sh $brewCasks
./scriptlets/setup-brews.sh $brews
./scriptlets/setup-oh-my-zsh.sh
./scriptlets/setup-git.sh
./scriptlets/setup-nvm.sh
./scriptlets/setup-npm-globals.sh $npmGlobals
./scriptlets/setup-go.sh
echo ""
echo "complete"