# Class: datware-resource::git-clone
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
class dataware-resource::git-clone {

  package{'git':
   ensure=>present,
  }

  exec{'git-clone':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => 'git clone git://github.com/horizon-institute/dataware.hwresource.git',
    cwd => '/usr/share',
    require => Package['git']
  }  
 
  file{'/usr/share/dataware.hwresource/src/prefstore/venv':
    ensure => absent,
    require => Exec['git-clone'],
  }

  file{'dataware.hwresource':
    path => '/usr/share/dataware.hwresource',
    owner => 'vagrant',
    group => 'vagrant',
    recurse => 'true', 
    require => [File['/usr/share/dataware.hwresource/src/prefstore/venv'], Exec['git-clone']],
  }

  file{'dataware_config_dir':
    path => "/etc/dataware/",
    ensure => directory,
    owner => vagrant,
    group => vagrant,
    mode => 644,
    require => File['dataware.hwresource'],
  }
  
  file{'sample_config.cfg':
    path => "/etc/dataware/sample_config.cfg",
    owner => vagrant,
    group => vagrant,
    mode  => 644,
    require => File['dataware_config_dir'],
    content => template("dataware-resource/dataware.erb"),
  }

  notify{'successfully cloned dataware-resource src to /usr/share':
    require => File['dataware.hwresource'],
  }
}
