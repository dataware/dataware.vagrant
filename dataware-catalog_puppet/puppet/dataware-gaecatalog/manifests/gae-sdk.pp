# Class: datware-gaecatalog::gae-sdk
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
class dataware-gaecatalog::gae-sdk {

  exec{'get-gae':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => 'wget http://googleappengine.googlecode.com/files/google_appengine_1.7.4.zip',
    cwd => '/usr/share',
  }  

  exec{'unzip-gae':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => 'unzip google_appengine_1.7.4.zip',
    cwd => '/usr/share',
    require => Exec['get-gae']
  }

  file{'remove-zip':
    path => "/usr/share/google_appengine_1.7.4.zip",
    require => Exec['unzip-gae'],
    ensure => absent
  }

  notify{'successfully retrieved gae python sdk':
    require => Exec['get-gae'],
  }
}
