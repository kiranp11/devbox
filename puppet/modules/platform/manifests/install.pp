class platform::install {
  package{ "openjdk-6-jdk":
    ensure => present;
  }

  file {"/tmp/hadoop.deb":
    source => "puppet:///platform/hadoop_1.0.3-1_x86_64.deb"
  }

  exec {"dpkg -i /tmp/hadoop.deb":
    require => File["/tmp/hadoop.deb"]
  }

}
