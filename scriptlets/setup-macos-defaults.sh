#! /bin/bash
# Annoying macos stuff
echo -n "setting key repeat... "
defaults write -g InitialKeyRepeat -int 13 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 2 # normal minimum is 2 (30 ms)
echo "done"
echo -n "cleaning toolbar... "
defaults write com.apple.dock persistent-apps -array
echo "done"