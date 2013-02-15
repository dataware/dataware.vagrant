Vagrant dataware boxes

Overview
--------

This repo is an attempt to automate the building and running of the three dataware components: catalog, resource and client on a local machine, to remove the requirement for accounts on heroku, ec2 and google app engine.  Each component runs out of a vagrant virtual machine, and it is assumed that this is running on your machine.  The installation and configuration of each of the components is handled by puppet (the non-enterprise version).

Getting started
---------------

For full details on getting the environment setup, see: http://docs.vagrantup.com/v1/getting-started/index.html.

Once you have this installed, clone this repo:

git clone git://github.com/horizon-institute/dataware.vagrant.git

This will create three directories and a vagrant box template under dataware.vagrant:

    dataware-catalog_puppet		dataware-client_puppet		dataware-resource_puppet	dataware.box
    
Each directory has Vagrantfile which configures and specifies the base virtual machine.   There is a set of puppet manifest files and an init.sh script.  All of these are available under /vagrant on your virtual machine.  To get started, you need to install the base vagrant box:
	
    vagrant box add dataware_squeeze64 dataware.box

now cd to one of the directories:

    cd dataware-catalog_puppet
    
Build the box (can take a while first time round as the base box is pulled down from a remote server):

    vagrant up
    
Once up, you can ssh to it:

    vagrant ssh
    
And you are now ready to configure the box using puppet.  All of this is done using the init.sh script:  

    cd /vagrant
    ./init.sh
    
This will set a proxy, untar the puppet module(s) into puppet's modulepath (/usr/share/puppet/modules- see: (see docs.puppetlabs.com/puppet/2.7/reference/modules_fundamentals.html) and run puppet.  This should pull down the relevant packages, set up the relevant configuration files, databases and dependencies and set up the component as a service.   Assuming all goes well, you should be able to run:

   sudo service dataware-[catalog | client | resource] start  
   
To access the boxes from a web browser, each component's Vagrantfile provides the vm with an IP address and a forwarded port.  

To access the dataware-catalog, go to:

    http://192.168.33.10:5000

For the dataware-resource:

    http://192.168.33.12:7000
    
And for the dataware-client:

     http://192.168.33.15:9090
     
To modify how the vms are built, take a look at /usr/share/puppet/modules/dataware-[catalog|client|resource]/manifests

The init.pp sets up a bunch of configuration parameters and specifies the ordering of each of the classes used to build the vm.  Note that these are very simple at the moment, and could be substantially improved to deal with partial builds and different base boxes.  




    
