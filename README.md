# Setup a Mac

Setup config to take an empty mac and build out a decent programming environment with iterm and zsh and a host of other useful tools.

Uses mostly brew and you should be able to run this straight from a brand new mac with a standard shell.

## Run it

```bash
bash -c "$(curl -H 'Cache-Control: no-cache, no-store' -fsSL https://raw.githubusercontent.com/codeallthethingz/brew-mac-setup/master/setup.sh)"
```

## Modify it

Most of the programs are set in the arrays at the top of the script using brew and brew cask.
