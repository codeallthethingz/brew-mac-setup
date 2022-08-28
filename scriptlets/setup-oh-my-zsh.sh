#! /bin/bash
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