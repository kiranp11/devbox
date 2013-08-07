class platform {

   package{ "openjdk-6-jdk":
     ensure => present;
   }

   file {"/tmp/hadoop.deb":
      source => "puppet:///modules/platform/hadoop_1.0.3-1_x86_64.deb"
   }

   file {"/etc/profile":
      source => "puppet:///modules/platform/profile"
   }

   exec {"dpkg -i /tmp/hadoop.deb":
     logoutput => true,
     require => File["/tmp/hadoop.deb"]
   }

}

