class dataware-client::client-startup {

  file{'/usr/local/bin/dataware-client':
      ensure  =>file,
      content =>template('dataware-client/client.erb'),
      mode    =>'755',
  }

  file {'/etc/init.d/dataware-client':
      ensure=>file,
      source=>'puppet:///modules/dataware-client/dataware-client.service',
      mode=>755,
  }
}

