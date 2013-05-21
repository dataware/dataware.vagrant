# Class: datware-resource::virtualenv
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
class dataware-resource::virtualenv {

  exec{'virtualenv':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => "pip install virtualenv",
    cwd => '/tmp',
  }
  
  exec{'virtualenv-create':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => "virtualenv venv",
    cwd => '/usr/share/dataware.hwresource/src',
    require => Exec['virtualenv'],
  }

  file{'/usr/share/dataware.hwresource/src/venv':
     owner => "vagrant",
     group => "vagrant",
     recurse => "true",
     require => Exec['virtualenv-create'],
  }	
}
