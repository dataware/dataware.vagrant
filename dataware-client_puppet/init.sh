#!/bin/sh
export http_proxy="http://mainproxy.nottingham.ac.uk:8080"

sudo mkdir /usr/share/puppet
sudo mkdir /usr/share/puppet/modules
cd /usr/share/puppet/modules
sudo tar -xvf /vagrant/dataware-client_puppet_modules.tar

#update the package manager to support backports
#echo "Acquire::http::Proxy \"http://mainproxy.nottingham.ac.uk:8080\";" | sudo tee -a /etc/apt/apt.conf.d/01Proxy
#echo "deb http://backports.debian.org/debian-backports squeeze-backports main" | sudo tee -a /etc/apt/sources.list
#sudo apt-get update
#sudo apt-get -t squeeze-backports install puppet

sudo -E puppet apply -e "include dataware-client" 
