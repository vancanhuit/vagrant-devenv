#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get --yes dist-upgrade
sudo apt-get --yes install git vim curl wget htop tmux jq tree net-tools

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

cp -v /vagrant/.vimrc ~/.vimrc
cp -v /vagrant/.tmux.conf ~/.tmux.conf

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/
rm -fv ./kubectl

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
sudo install -o root -g root -m 0755 kind /usr/local/bin/
rm -fv ./kind

curl -Lo ./starship.tar.gz https://github.com/starship/starship/releases/download/v1.11.0/starship-x86_64-unknown-linux-gnu.tar.gz
tar -zxvf starship.tar.gz
sudo install -o root -g root -m 0755 starship /usr/local/bin
rm -fv ./starship.tar.gz starship

echo 'eval "$(starship init bash)"' >> ~/.bashrc

mkdir -pv ~/.config
cp -v /vagrant/starship.toml ~/.config/
