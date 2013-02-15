# Class: dataware-gaecatalog::gae-start
#
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
class dataware-gaecatalog::gae-start {

  file{'/usr/local/bin/dataware-catalog':
      ensure  =>file,
      content =>template('dataware-gaecatalog/catalog.erb'),
      mode    =>'755',
  }
  
  file {'/usr/share/dataware.gaecatalog/settings.py':
      content => template('dataware-gaecatalog/settings.erb'),
  }
	
  file {'/etc/init.d/dataware-catalog':
      ensure=>file,
      source=>'puppet:///modules/dataware-gaecatalog/dataware-catalog.service',
      mode=>755,
  }
}
