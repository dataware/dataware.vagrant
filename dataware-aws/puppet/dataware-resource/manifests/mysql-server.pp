class dataware-resource::mysql-server{

 package{'mysql-server':
	ensure=>installed,
 } 

 service{'mysql':
        require => Package['mysql-server'],
        ensure => running,
        enable => true,
 }

 exec{'set-mysql-password':
	unless => "mysqladmin -uroot -p$db_root_password status",
	path =>   ["/bin", "/usr/bin"],
	command => "mysqladmin -uroot password $db_root_password",
        require => Service['mysql'],
 }
 
 
}
