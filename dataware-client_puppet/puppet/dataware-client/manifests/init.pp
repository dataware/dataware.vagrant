# Class: dataware-client 
#
# This module manages the dataware-client 
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
class dataware-client {
  
 
  $db_password      = "d8tawar3"
  $db_user          = "dataware"
  $db_name	    = "dataware"
  $db_host	    = "127.0.0.1"
  $db_port	    = "5432"
  $db_uri	    = "postgresql://${db_user}:${db_password}@${db_host}:${db_port}/${db_name}" 
  $catalog_url	    = "http://192.168.33.10:5000"
  $port	            = 9090 

  include dataware-client::proxy
  include postgresql::server
  include dataware-client::postgresql-databases
  include dataware-client::git-clone
  include dataware-client::pip
  include dataware-client::virtualenv
  include dataware-client::python-deps
  include dataware-client::client-startup
 
  Class['dataware-client::proxy'] -> Class['postgresql::server'] -> Class['dataware-client::postgresql-databases'] -> Class['dataware-client::git-clone'] -> Class['dataware-client::pip']-> Class['dataware-client::virtualenv'] -> Class['dataware-client::python-deps'] -> Class['dataware-client::client-startup']

}
