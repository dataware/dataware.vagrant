class dataware-resource::resource-startup {

  file{'/usr/local/bin/dataware-resource':
      ensure  =>file,
      content =>template('dataware-resource/resource.erb'),
      mode    =>'755',
  }

  file {'/etc/init.d/dataware-resource':
      ensure=>file,
      source=>'puppet:///modules/dataware-resource/dataware-resource.service',
      mode=>755,
  }
}

