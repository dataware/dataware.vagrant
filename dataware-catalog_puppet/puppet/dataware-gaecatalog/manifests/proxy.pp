# Class: datware-gaecatlog::proxy 
#
# This module sets up a proxy and downloads the latest packages 
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class dataware-gaecatalog::proxy {

	file{ 'proxy':
      	   ensure=> present,
           path => '/etc/apt/apt.conf.d/01Proxy',
           content => "Acquire::http::Proxy \"http://mainproxy.nottingham.ac.uk:8080\";\n", 
	}

	exec {"apt-update": 	
	  command => "/usr/bin/apt-get update" 
	}

}
