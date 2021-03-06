# Manage an otrs installation with
# all its dependencies
class otrs::base {
  include mod_perl
  include gpg
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
  require perl::extensions::ldap
  require perl::extensions::yaml_libyaml
  require perl::extensions::crypt_ssleay

  package{'otrs':
    ensure  => present,
    notify  => Exec['restart_otrs_cron'],
  }
  if $otrs::local_mysql {
    include mysql::server
    Package['otrs'] {
      require => Package['mysql-server','mod_perl'],
    }
  } else {
    Package['otrs'] {
      require => Package['mod_perl'],
    }
  }

  file{'/etc/sysconfig/otrs':
    source  => ["puppet:///modules/site_otrs/sysconfig/${::fqdn}/otrs",
                'puppet:///modules/site_otrs/sysconfig/otrs',
                "puppet:///modules/otrs/sysconfig/${::operatingsystem}/otrs",
                'puppet:///modules/otrs/sysconfig/otrs' ],
    require => Package['otrs'],
    notify  => Service['otrs'],
    owner   => root,
    group   => 0,
    mode    => '0644';
  }

  service{'otrs':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package[otrs],
  }

  file{
    '/etc/httpd/conf.d/otrs.conf':
      source  => ["puppet:///modules/site_otrs/httpd/${::fqdn}/otrs.conf",
                  'puppet:///modules/site_otrs/httpd/otrs.conf',
                  'puppet:///modules/otrs/httpd/otrs.conf' ],
      require => [ Package['otrs'], Package['apache'] ],
      notify  => Service['apache'],
      owner   => root,
      group   => 0,
      mode    => '0644';
    '/opt/otrs/Kernel/Config.pm':
      source  => ["puppet:///modules/site_otrs/config/${::fqdn}/Config.pm",
                  'puppet:///modules/site_otrs/config/Config.pm',
                  'puppet:///modules/otrs/config/Config.pm' ],
      require => Package['otrs'],
      notify  => [Service['otrs'], Exec['otrs.RebuildConfig.pl']],
      owner   => otrs,
      group   => apache,
      mode    => '0640';
  }
  exec{'otrs.RebuildConfig.pl':
    command     => '/opt/otrs/bin/otrs.RebuildConfig.pl',
    refreshonly => true,
    notify      => Service['otrs'],
  }

  file{
    '/opt/otrs/.gnupg':
      ensure  => directory,
      require => [ Package['otrs'], Package['apache'] ],
      owner   => apache,
      group   => apache,
      mode    => '0600';
    '/var/log/otrs':
      ensure  => directory,
      require => [ Package['otrs'], Package['apache'] ],
      owner   => otrs,
      group   => apache,
      mode    => '0660';
    '/var/log/otrs/otrs.log':
      ensure  => present,
      require => [ Package['otrs'], Package['apache'] ],
      owner   => otrs,
      group   => apache,
      mode    => '0660';
    '/etc/logrotate.d/otrs':
      source  => 'puppet:///modules/otrs/logrotate/otrs',
      require => [ Package['otrs'], Package['apache'] ],
      owner   => root,
      group   => 0,
      mode    => '0644';
  }

  exec{'restart_otrs_cron':
    command     => '/opt/otrs/bin/Cron.sh restart otrs',
    refreshonly => true,
  }
}
