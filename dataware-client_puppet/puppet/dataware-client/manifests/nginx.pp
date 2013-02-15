class dataware-client::nginx{

 package{'nginx':
	ensure=>installed,
 } 

 service{'nginx':
        require => Package['nginx'],
        ensure => running,
        enable => true,
 }

}
