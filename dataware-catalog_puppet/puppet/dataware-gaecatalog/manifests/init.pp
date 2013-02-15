# Class: dataware-gaecatalog 
#
# This module manages the dataware-gaecatalog 
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
class dataware-gaecatalog {
  $port = 5000 
  include dataware-gaecatalog::proxy
  include dataware-gaecatalog::unzip
  include dataware-gaecatalog::gae-sdk
  include dataware-gaecatalog::git-clone
  include dataware-gaecatalog::pip
  include dataware-gaecatalog::virtualenv
  include dataware-gaecatalog::gae-start
  
  Class['dataware-gaecatalog::proxy'] -> Class['dataware-gaecatalog::unzip'] -> Class['dataware-gaecatalog::gae-sdk'] -> Class['dataware-gaecatalog::git-clone'] -> Class['dataware-gaecatalog::pip']-> Class['dataware-gaecatalog::virtualenv'] -> Class['dataware-gaecatalog::gae-start']

}
