#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

update_system() {
    sudo apt-get update
    sudo apt-get -y dist-upgrade
}

install_basic_tools() {
    sudo apt-get -y install git vim curl wget \
                    htop tmux jq tree net-tools \
                    ca-certificates gnupg

    cp -v /vagrant/.vimrc ~/.vimrc
    cp -v /vagrant/.tmux.conf ~/.tmux.conf
    git clone --progress https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

install_starship() {
    curl -Lo ./starship.tar.gz https://github.com/starship/starship/releases/download/v1.15.0/starship-x86_64-unknown-linux-gnu.tar.gz
    tar -zxvf starship.tar.gz
    sudo install -o root -g root -m 0755 starship /usr/local/bin
    rm -fv ./starship.tar.gz starship
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
    mkdir -pv ~/.config
    # https://starship.rs/config/
    cp -v /vagrant/starship.toml ~/.config/
}

install_docker() {
    # https://docs.docker.com/engine/install/debian/
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli \
                    containerd.io docker-buildx-plugin \
                    docker-compose-plugin
    # https://docs.docker.com/engine/install/linux-postinstall/
    getent group docker || sudo groupadd docker
    sudo usermod -aG docker $USER
}

install_k8s_tools() {
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/
    rm -fv ./kubectl

    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    sudo install -o root -g root -m 0755 kind /usr/local/bin/
    rm -fv ./kind
}

INSTALL_STARSHIP=${INSTALL_STARSHIP:-no}
INSTALL_DOCKER=${INSTALL_DOCKER:-no}
INSTALL_K8S_TOOLS=${INSTALL_K8S_TOOLS:-no}

update_system
install_basic_tools
[[ ${INSTALL_STARSHIP} == no ]] || install_starship
[[ ${INSTALL_DOCKER} == no ]] || install_docker
[[ ${INSTALL_K8S_TOOLS} == no ]] || install_k8s_tools
