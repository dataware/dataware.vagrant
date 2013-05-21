# Class: dataware-resource 
#
# This module manages the dataware-resource 
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
class dataware-resource {

  $db_root_password = "pa55w0rd"
  $db_password      = "d8tawar3"
  $db_user          = "dataware"
  $resource_db	    = "myresource"
  $dataware_db      = "mydataware"

  $resources      = ["urls", "energy"]
  $resourcename	  = "myresource"
  $port		  = "7000"

  $catalog_uri	  = "http://192.168.33.10:5000"
  
  include dataware-resource::proxy
  include dataware-resource::nginx
  include dataware-resource::git-clone
  include dataware-resource::pip
  include dataware-resource::virtualenv
  include dataware-resource::python-deps
  include dataware-resource::mysql-server
  include dataware-resource::mysql-databases
  include dataware-resource::resource-startup  

#Class['dataware-resource::proxy'] -> 
  Class['dataware-resource::nginx'] -> Class['dataware-resource::git-clone'] -> Class['dataware-resource::pip']-> Class['dataware-resource::virtualenv'] -> Class['dataware-resource::python-deps'] -> Class['dataware-resource::mysql-server'] -> Class['dataware-resource::mysql-databases'] -> Class['dataware-resource::resource-startup']

}
