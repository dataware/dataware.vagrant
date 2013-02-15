# Class: datware-gaecatalog::git-clone
#
# This module fetches the latest src of the dataware-resource 
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
class dataware-gaecatalog::git-clone {

  package{'git':
    ensure=>present,
  }

  exec{'git-clone':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => 'git clone git://github.com/horizon-institute/dataware.gaecatalog.git',
    cwd => '/usr/share',
    require => Package['git'],
  }  

  file{'dataware.gaecatalog':
    path => '/usr/share/dataware.gaecatalog',
    owner => 'vagrant',
    group => 'vagrant',
    recurse => 'true', 
    require => Exec['git-clone'],
  }

  notify{'successfully cloned dataware-gaecatalog src to /usr/share':
    require => File['dataware.gaecatalog'],
  }
}
