# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-12"

  config.vm.network "private_network", ip: "192.168.56.10"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.provision "shell" do |s|
    s.name = "setup"
    s.path = "setup.sh"
    s.privileged = false
    s.reboot = true
    s.env = {
      "INSTALL_STARSHIP" => ENV["INSTALL_STARSHIP"] || "",
      "INSTALL_DOCKER" => ENV["INSTALL_DOCKER"] || "",
      "INSTALL_K8S_TOOLS" => ENV["INSTALL_K8S_TOOLS"] || "",
    }
  end
end
