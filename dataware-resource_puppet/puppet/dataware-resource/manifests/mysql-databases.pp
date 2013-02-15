class dataware-resource::mysql-databases{
 
 define mysqldb( $user, $password ) {
    exec { "create-${name}-db":
      unless => "/usr/bin/mysql -u${user} -p${password} ${name}",
      command => "/usr/bin/mysql -uroot -p$db_root_password -e \"create database ${name}; grant all on ${name}.* to ${user}@localhost identified by '$password';\"",
    }
  }
  
  mysqldb { "$resource_db":
        user => "dataware",
        password => "d8tawar3",
  }

  mysqldb { "$dataware_db":
        user => "dataware",
        password => "d8tawar3",
  }

}
 
