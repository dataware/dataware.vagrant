# Class: datware-resource::pip
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
class dataware-resource::pip {

  exec{'get-distutils':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => 'wget http://peak.telecommunity.com/dist/ez_setup.py',
    cwd => '/tmp',
  } 

  exec{'distutils-install':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => 'python ez_setup.py',
    cwd => '/tmp', 
    require => Exec['get-distutils']
  }

  exec{'get-pip':
    path => "/usr/local/bin:/usr/bin/:/bin/",   
    command => 'wget --no-check-certificate https://raw.github.com/pypa/pip/master/contrib/get-pip.py',
    cwd => '/tmp',
    require => Exec['distutils-install'],
  }

  exec{'pip-install':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => "python get-pip.py",
    cwd => '/tmp',
    require => Exec['get-pip'],
  }
  
  notify{'successfully installed pip!':
    require => Exec['pip-install'],
  }
}
