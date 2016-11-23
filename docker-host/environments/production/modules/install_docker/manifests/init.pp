include apt
require 'facter'
class install_docker {


  # create docker group
  group { 'docker':
    ensure => 'present'
  }

  # declare vagrant user as a virtual resource
  # http://serverfault.com/a/416284/135880
  # https://docs.puppet.com/puppet/latest/reference/lang_virtual.html#declaring-a-virtual-resource
  @user { 'vagrant':
    groups     => ['vagrant','docker'],
  }

  # realize virtual resource above.
  realize(User['vagrant'])


  # function to retrieve remote file
  define remote_file($remote_location=undef, $mode='0644'){
    exec{"retrieve_${title}":
    command => "/usr/bin/wget -q ${remote_location} -O ${title}",
    creates => $title,
    }

    file{$title:
      mode    => $mode,
      require => Exec["retrieve_${title}"],
    }
  }

  # always update
  class { 'apt':
      update => {
        frequency => 'always'
      }
  }

  # docker key
  # apt::key {'58118E89F3A912897C070ADBF76221572C52609D':
  #   options => '--keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D',
  # } ->  # docker source

  apt::key {'58118E89F3A912897C070ADBF76221572C52609D':
    id => '58118E89F3A912897C070ADBF76221572C52609D',
    server => 'hkp://ha.pool.sks-keyservers.net:80',
  }

  apt::source { 'docker':
  location => 'http://apt.dockerproject.org/repo',
  repos    => 'main',
  release  => 'ubuntu-trusty',
  notify  => Exec['apt_update'],
  } ~>  # packages
  package { 'apt-transport-https':
    ensure => 'latest',
    require => Exec['apt_update']
  } ~>
  package { 'ca-certificates':
    ensure => 'latest'
  } ~>
  package {"linux-image-extra-$kernelrelease":
    ensure => 'latest'
  } ~>
  package {'linux-image-extra-virtual':
    ensure => 'latest'
  } ~>  # install docker
  package {"docker-engine":
    ensure => 'latest'
  } ~>
  # deploy templated docker conf.
  file {'/etc/default/docker':
    ensure => file,
    content => template('install_docker/docker.conf'),
    notify => Service['docker'],
    mode => '0644',
    owner => 'root',
    group => 'root'
  }

  # ensure docker service running.
  service {'docker':
    ensure => 'running'
  }
  # download docker compose
  remote_file{'/usr/local/bin/docker-compose':
    remote_location => 'https://github.com/docker/compose/releases/download/1.8.0/docker-compose-Linux-x86_64',
    mode            => '0666',
  }
}