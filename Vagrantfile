# -*- mode: ruby -*-
# vi: set ft=ruby :

NUM_SLAVES=2
# master IP becomes: 192.168.56.100
PRIVATE_SUBNET="192.168.56"
IP_BASE=100
MASTER_IP="#{PRIVATE_SUBNET}.#{IP_BASE}"
# master uses SSH_PORT_BASE, and the slaves use ports counting from that
SSH_PORT_BASE=5622

puts "Creating k8s cluster with 1 master and #{NUM_SLAVES} slaves"
puts "IP addresses will be #{MASTER_IP} onwards"

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"
  config.vm.provision "shell", inline: <<-SHELL
       which python || ( apt-get update; apt-get install -y python)
  SHELL

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = 'provision/kubernetes.yml'
    ansible.sudo = true
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
  end

  (1..NUM_SLAVES).each do |i|
    hostname="node-#{i}"
    config.vm.define hostname do |node|
      node.vm.hostname = hostname
      node.vm.network :private_network, ip: "#{PRIVATE_SUBNET}.#{i+IP_BASE}"
      node.vm.network :forwarded_port, guest: 22, host: (SSH_PORT_BASE+i), id: "ssh"
      node.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["modifyvm", :id, "--memory", 1024]
        v.customize ["modifyvm", :id, "--name", hostname]
      end
    end
  end
end
