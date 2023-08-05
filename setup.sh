#!/bin/bash

set -o errexit

# https://www.cyberciti.biz/faq/explain-debian_frontend-apt-get-variable-for-ubuntu-debian/
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

update_system() {
    sudo apt-get update
    sudo apt-get --quiet --yes \
                --option "Dpkg::Options::=--force-confdef" \
                --option "Dpkg::Options::=--force-confold" dist-upgrade

    latest_kernel_version=$(sudo find /boot/ -name 'vmlinuz-*' -printf "%T+ %p\n" | sort -r | head -1 | awk '{print $2}' | xargs -n 1 basename | sed -n 's/vmlinuz-//p')
    sudo apt-get install --quiet --yes linux-headers-${latest_kernel_version}
}

install_basic_tools() {
    sudo apt-get --quiet --yes install git vim curl wget \
                    htop tmux jq tree net-tools \
                    ca-certificates gnupg

    cp --verbose /vagrant/.vimrc ~/.vimrc
    cp --verbose /vagrant/.tmux.conf ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

install_starship() {
    curl --location --output ./starship.tar.gz https://github.com/starship/starship/releases/download/v1.16.0/starship-x86_64-unknown-linux-gnu.tar.gz
    tar --verbose --gunzip --extract --file starship.tar.gz
    sudo install --owner=root --group=root --mode=0755 starship /usr/local/bin
    rm --force --verbose ./starship.tar.gz starship
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
    mkdir --parents --verbose ~/.config
    # https://starship.rs/config/
    cp --verbose /vagrant/starship.toml ~/.config/
}

install_docker() {
    # https://docs.docker.com/engine/install/debian/
    sudo install --mode=0755 --directory /etc/apt/keyrings
    curl --fail --silent --show-error --location https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor --output /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install --quiet --yes docker-ce docker-ce-cli \
                    containerd.io docker-buildx-plugin \
                    docker-compose-plugin
    # https://docs.docker.com/engine/install/linux-postinstall/
    getent group docker || sudo groupadd docker
    sudo usermod --append --groups docker $USER
}

install_k8s_tools() {
    curl --location --remote-name "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install --owner=root --group=root --mode=0755 kubectl /usr/local/bin/
    rm --force --verbose ./kubectl

    curl --location --output ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    sudo install --owner=root --group=root --mode=0755 kind /usr/local/bin/
    rm --force --verbose ./kind
}

update_system
install_basic_tools
[[ -z ${INSTALL_STARSHIP:-} ]] || install_starship
[[ -z ${INSTALL_DOCKER:-} ]] || install_docker
[[ -z ${INSTALL_K8S_TOOLS:-} ]] || install_k8s_tools
