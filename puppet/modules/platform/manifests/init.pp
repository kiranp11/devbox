class platform {

    package{ "openjdk-6-jdk":
        ensure => present;
    }

    file {"/etc/profile":
        source => "puppet:///modules/platform/profile"
    }

    exec { "create-folders" :
        command   => "mkdir -p /var/log/hadoop",
        logoutput => true
    }

    exec { "get-hadoop-tar" :
        command   => "wget http://archive.apache.org/dist//hadoop/core/hadoop-1.0.3/hadoop-1.0.3-bin.tar.gz -O /tmp/hadoop-1.0.3-bin.tar.gz",
        logoutput => true,
        unless    => "test -f /tmp/hadoop-1.0.3-bin.tar.gz",
        timeout   => 0
    }

    exec { "get-hive-tar" :
        command   => "wget http://apache.mirrors.pair.com/hive/hive-0.11.0/hive-0.11.0-bin.tar.gz -O /tmp/hive-0.11.0-bin.tar.gz",
        logoutput => true,
        unless    => "test -f /tmp/hive-0.11.0-bin.tar.gz",
        timeout   => 0
    }

    exec { "untar-hadoop" :
        command   => "tar -xvf /tmp/hadoop-1.0.3-bin.tar.gz",
        logoutput => true,
        cwd       => "/usr/local",
        require   => Exec["get-hadoop-tar"]
    }

    exec { "untar-hive" :
        command   => "tar -xvf /tmp/hive-0.11.0-bin.tar.gz",
        logoutput => true,
        cwd       => "/usr/local",
        require   => Exec["get-hive-tar"]
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

    file { "/usr/local/hive":
        ensure => "/usr/local/hive-0.11.0-bin",
        require => Exec["untar-hive"]
    }

    file {"/usr/local/hadoop/conf/hadoop-env.sh":
        source => "puppet:///modules/platform/hadoop-env.sh",
        require => Exec["untar-hadoop"]
    }

    exec { "chown-vagrant":
        command => "chown -R vagrant:vagrant /usr/local/hadoop* /var/log/hadoop /usr/local/hive*",
        require => [ File["/usr/local/hadoop"] , Exec["create-folders"], File["/usr/local/hive"]]
    }

    file { "/home/vagrant/.ssh/id_dsa":
        source  => "puppet:///modules/platform/hadoop_dsa",
        mode    => 600,
        owner   => "vagrant",
        group   => "vagrant"
    }

    file { "/home/vagrant/.ssh/id_dsa.pub":
        source => "puppet:///modules/platform/hadoop_dsa.pub",
        mode    => 600,
        owner   => "vagrant",
        group   => "vagrant"
    }

    exec { "update-auth-keys":
        command => "cat /home/vagrant/.ssh/id_dsa.pub >> /home/vagrant/.ssh/authorized_keys",
        require => File["/home/vagrant/.ssh/id_dsa.pub"];
    }

    exec { "add-to-known_hosts":
        command => "ssh-keyscan localhost >> /home/vagrant/.ssh/known_hosts",
        unless  => "grep -iq localhost /home/vagrant/.ssh/known_hosts",
        require => File["/home/vagrant/.ssh/id_dsa.pub"];
    }

    exec { "format-namenode":
        command => "/usr/local/hadoop/bin/hadoop namenode -format",
        require =>  [ Exec["update-auth-keys"], Exec["chown-vagrant"]],
        unless  => "test -d /tmp/hadoop-vagrant/dfs/name",
        user    => "vagrant"
    }

     exec { "start-hadoop-demons":
        cwd       => "/usr/local/hadoop/bin/",
        command   => "nohup /usr/local/hadoop/bin/start-all.sh > /dev/null",
        require =>  [Exec["format-namenode"], Exec["add-to-known_hosts"]],
        user    => "vagrant"
    }
}

