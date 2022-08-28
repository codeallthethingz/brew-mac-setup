#! /bin/bash

# Go paths
echo 'export GOPATH="${HOME}/.go"' >> ~/.zshrc-ext
echo 'export GOROOT="$(brew --prefix golang)/libexec"' >> ~/.zshrc-ext
echo 'export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"' >> ~/.zshrc-ext
