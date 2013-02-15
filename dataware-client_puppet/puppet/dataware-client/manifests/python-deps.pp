# Class: dataware-client::python-deps
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
class dataware-client::python-deps {

  package{'python-dev':
	ensure => installed,
  }
  
  package{'libevent-dev':
	ensure =>installed,
  }
  
  package{'libpq-dev':
	ensure =>installed,
  }

  exec{'pip-Flask':
    command => "/usr/share/dataware.herokuclient/venv/bin/pip install Flask",
  }

  exec{'pip-psycopg2':
    command => "/usr/share/dataware.herokuclient/venv/bin/pip install psycopg2",
    require => [Package['python-dev'], Package['libpq-dev']]
  }

  exec{'pip-gevent':
    command => "/usr/share/dataware.herokuclient/venv/bin/pip install gevent",
    require => [Package['libevent-dev'], Package['python-dev']]
  }  
 
  exec{'pip-SQLAlchemy':
    command => "/usr/share/dataware.herokuclient/venv/bin/pip install SQLAlchemy",
  } 
}
