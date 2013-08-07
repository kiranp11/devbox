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

    file { "/usr/local/hadoop":
        ensure => "/usr/local/hadoop-1.0.3",
        require => Exec["untar-hadoop"]
    }

    group { "hadoop":
        ensure => present,
        gid => 9999,
        require => Exec["untar-hadoop"]
    }

    exec {"mkdir -p /home/hadoop/.ssh":
       unless =>["test -d /home/hadoop/.ssh"] 
    }


    user { "hadoop":
        ensure     => present,
        gid        => "9999",
        groups     => ["adm", "hadoop", "root"],
        membership => minimum,
        require    => [ Group["hadoop"],Exec["mkdir /home/hadoop"]],
        home       => "/home/hadoop/"
    }

    # change the permissions of the Hadoop installation.
    exec { "chown-hadoop":
        command => "chown -R hadoop:hadoop /usr/local/hadoop* /var/log/hadoop",
        require => [ Group["hadoop"], User["hadoop"], File["/usr/local/hadoop"] ],
        subscribe => Exec["untar-hadoop"],
        refreshonly => true
    }

    file { "/home/hadoop/.ssh/id_dsa":
        source  => "puppet:///modules/platform/hadoop_dsa",
        mode    => 600,
        owner   => "hadoop",
        group   => "hadoop",
        require => User["hadoop"];
    }

    file { "/home/hadoop/.ssh/id_dsa.pub":
        source => "puppet:///modules/platform/hadoop_dsa.pub",
         mode    => 600,
        owner   => "hadoop",
        group   => "hadoop",
        require => User["hadoop"];
    }

    file { "/home/hadoop/.ssh/authorized_keys":
        source => "puppet:///modules/platform/hadoop_dsa.pub",
         mode    => 600,
        owner   => "hadoop",
        group   => "hadoop",
        require => User["hadoop"];
    }


}

