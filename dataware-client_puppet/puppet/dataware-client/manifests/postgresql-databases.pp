class dataware-client::postgresql-databases{
   
   pg_user{"${db_user}":
	ensure => present,
	password => $db_password,
        createdb => true,
   }

   pg_database{'dataware':
	ensure => present,
  	owner  => "${db_user}",
  	require => Pg_user["${db_user}"],
   }
}
 
