#!/bin/sh
#export http_proxy="http://mainproxy.nottingham.ac.uk:8080"
sudo apt-get update
sudo apt-get install puppet
sudo mkdir /usr/share/puppet
sudo mkdir /usr/share/puppet/modules
cd /usr/share/puppet/modules
sudo ln -s /vagrant/puppet/dataware-resource dataware-resource

sudo -E puppet apply -e "include dataware-resource" 
