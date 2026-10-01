# -*- mode: ruby -*-
# -*- encoding: utf-8 -*-
# vi: set ft=ruby :

## Variables

# You must get the small-ubuntu2204.box before :
#     gdown -O ./builds/small-ubuntu2204.box  1QM-BXuCwH_YFc20jgtNXMYVH4hsqs1DE
# then uncomment the line with 'node.vm.box_url' below
BOX_NAME = "small-ubuntu2204"
BOX_URL = "file://#{File.expand_path("builds/small-ubuntu2204.box", __dir__)}"

APP_NAME="ubuntu"
VM_NAME="ubuntu2204"
MY_IP="192.168.99.1"

## Vagrant version
Vagrant.require_version ">= 2.0.0"

## Plugins
unless Vagrant.has_plugin?("virtualbox")
  raise 'Missing virtualbox plugin! Make sure to install it by `vagrant plugin install virtualbox`.'
end

Vagrant.configure("2") do |node|

  node.vm.box = BOX_NAME
  node.vm.box_url = BOX_URL
  node.vm.hostname = APP_NAME

  node.vm.network "private_network", ip: MY_IP

  node.vm.provider "virtualbox"  do |vb|
    vb.name = VM_NAME
    vb.memory = 2048
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
  end

  node.ssh.insert_key = false

  node.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  node.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "ansible/playbook.yml"
    ansible.install = true
    ansible.limit = 'all'
  end

  node.vm.provision "shell", path: "scripts/finish.sh"

end
