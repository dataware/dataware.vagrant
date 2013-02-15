# Class: datware-gaecatalog::virtualenv
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
class dataware-gaecatalog::virtualenv {

  exec{'virtualenv':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => "pip install virtualenv",
    cwd => '/tmp',
  }
  
  exec{'virtualenv-create':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    command => "virtualenv venv",
    cwd => '/usr/share/dataware.gaecatalog',
    require => Exec['virtualenv'],
  }

  exec{'gaeify':
    path => "/usr/local/bin:/usr/bin/:/bin/",
    cwd  => "/usr/share/dataware.gaecatalog/venv",
    command => "echo '/usr/share/google_appengine' >> lib/python2.6/site-packages/gae.pth  && echo 'import dev_appserver; dev_appserver.fix_sys_path()' >> lib/python2.6/site-packages/gae.pth",
    require => Exec['virtualenv-create'],
  }
}
