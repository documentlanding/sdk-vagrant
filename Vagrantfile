# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # UBUNTU 14.04 LTS
  config.vm.box = "trusty64"
  config.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box"
  config.vm.provision :shell, :path => "setup.sh"

  config.vm.network "private_network", ip: "192.168.50.5"
  config.vm.network "forwarded_port", guest: 80, host: 4002
  config.vm.network "forwarded_port", guest: 3306, host: 3309
  config.vm.network "forwarded_port", guest: 22, host: 2200

  config.vm.provider :virtualbox do |vb| 
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

end