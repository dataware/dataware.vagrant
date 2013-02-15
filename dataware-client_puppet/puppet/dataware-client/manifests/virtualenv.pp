# Class: dataware-client::virtualenv
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
class dataware-client::virtualenv {

  exec{'virtualenv':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => "pip install virtualenv",
    cwd => '/tmp',
  }
  
  exec{'virtualenv-create':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => "virtualenv venv",
    cwd => '/usr/share/dataware.herokuclient',
    require => Exec['virtualenv'],
  }
}
