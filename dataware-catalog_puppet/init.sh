#!/bin/sh
export http_proxy="http://mainproxy.nottingham.ac.uk:8080"
sudo mkdir /usr/share/puppet
sudo mkdir /usr/share/puppet/modules
cd /usr/share/puppet/modules
sudo ln -s /vagrant/puppet/dataware-gaecatalog dataware-gaecatalog 
sudo -E puppet apply -e "include dataware-gaecatalog" 
