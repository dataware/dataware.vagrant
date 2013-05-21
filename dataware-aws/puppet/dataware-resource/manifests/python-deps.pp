# Class: datware-resource::python-deps
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
class dataware-resource::python-deps {

  package{'python-dev':
	ensure => installed,
  }
  
  package{'libmysqlclient-dev':
	ensure => installed,
  }

  package{'libevent-dev':
	ensure =>installed,
  }
  
  exec{'pip-bottle':
    command => "/usr/share/dataware.hwresource/src/venv/bin/pip install bottle",
  }

  exec{'pip-mysql-python':
    command => "/usr/share/dataware.hwresource/src/venv/bin/pip install MySQL-python",
    require => [Package['python-dev'], Package['libmysqlclient-dev']]
  }

  exec{'pip-gevent':
    command => "/usr/share/dataware.hwresource/src/venv/bin/pip install gevent",
    require => [Package['libevent-dev'], Package['python-dev']],
  }  
 
  exec{'pip-SQLAlchemy':
    command => "/usr/share/dataware.hwresource/src/venv/bin/pip install SQLAlchemy",
  } 
 
  exec{'pip-sqlparse':
     command => "/usr/share/dataware.hwresource/src/venv/bin/pip install sqlparse",
  }
}
