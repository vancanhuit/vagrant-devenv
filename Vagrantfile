# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  config.vm.network "private_network", ip: "192.168.56.10"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.provision "shell", 
    name: "install-essential-tools", 
    path: "setup.sh", 
    privileged: false, 
    env: {
      "INSTALL_STARSHIP" => "yes",
      "INSTALL_DOCKER" => "yes",
      "INSTALL_K8S_TOOLS" => "yes",
    }
end
