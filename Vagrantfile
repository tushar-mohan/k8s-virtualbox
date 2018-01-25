# -*- mode: ruby -*-
# vi: set ft=ruby :

# This Vagrantfile is for a single master, N slaves setup

NUM_SLAVES=(ENV['NUM_SLAVES'] || 2).to_i()
# master IP becomes: 192.168.56.100
SUBNET=(ENV['SUBNET'] || "192.168.56")
IP_BASE=100
MASTER_IP="#{SUBNET}.#{IP_BASE}"
# master uses SSH_PORT_BASE, and the slaves use ports counting from that
SSH_PORT_BASE=5622

post_up_msg = <<-MSG
    ------------------------------------------------------
    k8s cluster: master #{MASTER_IP}, #{NUM_SLAVES} slaves
    master: vagrant ssh master
    slaves are called node-1,...
    
    To use cluster:
    
    $ export KUBECONFIG=$PWD/kube.config
    $ kubectl ...
    
    To set up flannel:
    $ ./flannel.sh
    ------------------------------------------------------
MSG

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"
  config.vm.provision "shell", inline: <<-SHELL
       which python || ( apt-get update; apt-get install -y python)
  SHELL

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = 'kubernetes.yml'
    ansible.become = true
    ansible.host_vars = {
      "master" => {"private_ip" => MASTER_IP}
    }
  end

  config.vm.define "master", primary: true do |master|
    master.vm.hostname = 'master'
    master.vm.network :private_network, ip: MASTER_IP
    master.vm.network :forwarded_port, guest: 22, host: SSH_PORT_BASE, id: "ssh"
    master.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--name", "master"]
    end
    master.vm.post_up_message = post_up_msg
  end

  (1..NUM_SLAVES).each do |i|
    hostname="node-#{i}"
    config.vm.define hostname do |node|
      node.vm.hostname = hostname
      node.vm.network :private_network, ip: "#{SUBNET}.#{i+IP_BASE}"
      node.vm.network :forwarded_port, guest: 22, host: (SSH_PORT_BASE+i), id: "ssh"
      node.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["modifyvm", :id, "--memory", 1024]
        v.customize ["modifyvm", :id, "--name", hostname]
      end
    end
  end
  config.vm.post_up_message = post_up_msg
end
