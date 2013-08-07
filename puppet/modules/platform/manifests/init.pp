class platform {

    package{ "openjdk-6-jdk":
        ensure => present;
    }

    file {"/etc/profile":
        source => "puppet:///modules/platform/profile"
    }

    exec { "get-hadoop-tar" :
        command   => "wget http://archive.apache.org/dist//hadoop/core/hadoop-1.0.3/hadoop-1.0.3-bin.tar.gz -O /tmp/hadoop-1.0.3-bin.tar.gz",
        logoutput => true,
        unless    => "test -f /tmp/hadoop-1.0.3-bin.tar.gz",
        timeout   => 0
    }

    exec { "untar-hadoop" :
        command   => "tar -xvf /tmp/hadoop-1.0.3-bin.tar.gz",
        logoutput => true,
        cwd       => "/usr/local",
        require   => Exec["get-hadoop-tar"]
    }

    file {"/usr/local/hadoop-1.0.3/conf/core-site.xml":
        source => "puppet:///modules/platform/core-site.xml",
        require   => Exec["untar-hadoop"]
    }

    file {"/usr/local/hadoop-1.0.3/conf/mapred-site.xml":
        source => "puppet:///modules/platform/mapred-site.xml",
        require   => Exec["untar-hadoop"]
    }

    file {"/usr/local/hadoop-1.0.3/conf/hdfs-site.xml":
        source => "puppet:///modules/platform/hdfs-site.xml",
        require   => Exec["untar-hadoop"]
    }



}

