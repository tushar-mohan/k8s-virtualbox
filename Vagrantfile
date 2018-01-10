Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"
  config.vm.provision "shell", inline: <<-SHELL
       which python || ( apt-get update; apt-get install -y python)
  SHELL

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = 'provision/kubernetes.yml'
    ansible.sudo = true
    ansible.host_vars = {
      "stage1" => {"private_ip" => "192.168.56.101"}
    }
  end

  config.vm.define "stage1", primary: true do |stage1|
    stage1.vm.hostname = 'stage1'
    stage1.vm.network :private_network, ip: "192.168.56.101"
    stage1.vm.network :forwarded_port, guest: 22, host: 10122, id: "ssh"
    stage1.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--name", "stage1"]
    end
  end

  config.vm.define "stage2" do |stage2|
    stage2.vm.hostname = 'stage2'
    stage2.vm.network :private_network, ip: "192.168.56.102"
    stage2.vm.network :forwarded_port, guest: 22, host: 10222, id: "ssh"
    stage2.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--name", "stage2"]
    end
  end

  config.vm.define "stage3", autostart: false do |stage3|
    stage3.vm.hostname = 'stage3'
    stage3.vm.network :private_network, ip: "192.168.56.103"
    stage3.vm.network :forwarded_port, guest: 22, host: 10322, id: "ssh"
    stage3.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--name", "stage3"]
    end
  end
end
