#! /bin/bash

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

if [ ! -f  ~/.ssh/id_rsa ]; then
    echo ""
    echo "generating public private key pair with email $email"
    ssh-keygen -t rsa -b 4096 -C "$email" -q -N "" -f ~/.ssh/id_rsa
fi

echo "done"
