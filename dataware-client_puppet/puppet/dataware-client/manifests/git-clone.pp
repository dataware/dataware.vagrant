# Class: dataware-client::git-clone
#
# This module fetches the latest src of the dataware-client 
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
class dataware-client::git-clone {

  package{'git':
    ensure=>present,	
  }

  exec{'git-clone':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => 'git clone git://github.com/horizon-institute/dataware.herokuclient.git',
    cwd => '/usr/share',
    require => Package['git'],
  }  
 
  file{'venv':
    path => '/usr/share/dataware.herokuclient/venv',
    ensure => absent,
    force => true, 
    require => Exec['git-clone'],
  }

  file{'dataware.herokuclient':
    path => '/usr/share/dataware.herokuclient',
    owner => 'vagrant',
    group => 'vagrant',
    recurse => 'true', 
    require => [File['venv'], Exec['git-clone']],
  }

  file{'/usr/share/dataware.herokuclient/settings.py':
    mode => 644,
    require => File['dataware.herokuclient'],
    content => template("dataware-client/settings.erb"),
  }
  
  #file{'sample_config.cfg':
  #  path => "/etc/dataware/sample_config.cfg",
  #  owner => vagrant,
  #  group => vagrant,
  #  mode  => 644,
  #  require => File['dataware_config_dir'],
  #  content => template("dataware-client/dataware.erb"),
  #}

  notify{'successfully cloned dataware-client src to /usr/share':
    require => File['dataware.herokuclient'],
  }
}
