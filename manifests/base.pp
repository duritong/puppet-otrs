class otrs::base {
  include mod_perl
  include gpg
  if $otrs_nolocal_mysql {
    include mysql::disable
  } else {
    include mysql::server
  }
  require perl::extensions::dbd_mysql
  require perl::extensions::net_dns
  require perl::extensions::net_imap_simple_ssl
  require perl::extensions::bsd_resource
  require perl::extensions::xml_parser
  require perl::extensions::datetime
  require perl::extensions::json_xs
  require perl::extensions::pdf_api2
  require perl::extensions::text_csv_xs
  require perl::extensions::gd
  require perl::extensions::gdgraph
  require perl::extensions::gdtextutil
  require perl::extensions::timedate

  package{'otrs':
    ensure => present,
    require => Package['mysql-server','mod_perl'],
    notify => Exec['restart_otrs_cron'],
  }

  file{'/etc/sysconfig/otrs':
    source => [ "puppet:///modules/site_otrs/sysconfig/${fqdn}/otrs",
                "puppet:///modules/site_otrs/sysconfig/otrs",
                "puppet:///modules/otrs/sysconfig/${operatingsystem}/otrs",
                "puppet:///modules/otrs/sysconfig/otrs" ],
    require => Package['otrs'],
    notify => Service['otrs'],
    owner => root, group => 0, mode => 644;
  }

  service{'otrs':
    ensure => running,
    enable => true,
    hasstatus => true,
    require => Package[otrs],
  }

  file{'/etc/httpd/conf.d/otrs.conf':
    source => [ "puppet:///modules/site_otrs/httpd/${fqdn}/otrs.conf",
                "puppet:///modules/site_otrs/httpd/otrs.conf",
                "puppet:///modules/otrs/httpd/otrs.conf" ],
    require => [ Package['otrs'], Package['apache'] ],
    notify => Service['apache'],
    owner => root, group => 0, mode => 0644;
  }

  file{'/opt/otrs/Kernel/Config.pm':
    source => [ "puppet:///modules/site_otrs/config/${fqdn}/Config.pm",
                "puppet:///modules/site_otrs/config/Config.pm",
                "puppet:///modules/otrs/config/Config.pm" ],
    require => Package['otrs'], 
    notify => [Service['otrs'], Exec['otrs.RebuildConfig.pl']],
    owner => otrs, group => apache, mode => 0640;
  }
  exec{'otrs.RebuildConfig.pl':
    command => '/opt/otrs/bin/otrs.RebuildConfig.pl',
    refreshonly => true,
    notify => Service['otrs'],
  }

  file{
    '/opt/otrs/.gnupg':
      ensure => directory,
      require => [ Package['otrs'], Package['apache'] ],
      owner => apache, group => apache, mode => 0600;
    '/var/log/otrs':
      ensure => directory,
      require => [ Package['otrs'], Package['apache'] ],
      owner => otrs, group => apache, mode => 0660;
    '/var/log/otrs/otrs.log':
      ensure => present,
      require => [ Package['otrs'], Package['apache'] ],
      owner => otrs, group => apache, mode => 0660;      
  }

  file{'/etc/logrotate.d/otrs':
    source => 'puppet:///modules/otrs/logrotate/otrs',
    require => [ Package['otrs'], Package['apache'] ],
    owner => root, group => 0, mode => 0644;
  }

  exec{'restart_otrs_cron':
    command => '/opt/otrs/bin/Cron.sh restart otrs',
    refreshonly => true,
  }
}
