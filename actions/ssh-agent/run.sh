#!/bin/bash

mkdir -p ~/.ssh
echo ${{ inputs.ssh-private-key-base64 }} | base64 --decode > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
ssh-add -D
ssh-add ~/.ssh/id_rsa
ssh-keyscan github.com > ~/.ssh/known_hosts
git config --global user.name 'judo-ci'
git config --global user.email 'devops@judopay.com'
