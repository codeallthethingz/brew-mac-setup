#! /bin/bash
# Install Brew
echo -n "installing brew... "
HOMEBREW_NO_AUTO_UPDATE=1 
command -v brew >/dev/null 2>&1 || { echo >&2 "Installing Homebrew Now"; \
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; }
brew tap homebrew/cask-drivers
echo "done"