class otrs::base {
    include mod_perl
    include gpg
    if $otrs_nolocal_mysql {
        include mysql::disable
    } else {
        include mysql::server
    }
    include perl::extensions::dbd_mysql
    include perl::extensions::net_dns
    include perl::extensions::net_imap_simple_ssl
    include perl::extensions::bsd_resource

    package{'otrs':
        ensure => present,
        require => [ Package['mysql-server'], 
            Package['mod_perl'], Perl::Module['DBD-mysql'] ],
        notify => Exec['restart_otrs_cron'],
    }

    file{'/etc/sysconfig/otrs':
        source => [ "puppet://$server/modules/site-otrs/sysconfig/${fqdn}/otrs",
                    "puppet://$server/modules/site-otrs/sysconfig/otrs",
                    "puppet://$server/modules/otrs/sysconfig/${operatingsystem}/otrs",
                    "puppet://$server/modules/otrs/sysconfig/otrs" ],
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
        source => [ "puppet://$server/modules/site-otrs/httpd/${fqdn}/otrs.conf",
                    "puppet://$server/modules/site-otrs/httpd/otrs.conf",
                    "puppet://$server/modules/otrs/httpd/otrs.conf" ],
        require => [ Package['otrs'], Package['apache'] ],
        notify => Service['apache'],
        owner => root, group => 0, mode => 0644;
    }

    file{'/opt/otrs/Kernel/Config.pm':
        source => [ "puppet://$server/modules/site-otrs/config/${fqdn}/Config.pm",
                    "puppet://$server/modules/site-otrs/config/Config.pm",
                    "puppet://$server/modules/otrs/config/Config.pm" ],
        require => Package['otrs'], 
        notify => Service['otrs'],
        owner => root, group => 0, mode => 0644;
    }

    file{'/opt/otrs/.gnupg':
        ensure => directory,
        require => [ Package['otrs'], Package['apache'] ],
        owner => apache, group => apache, mode => 0700;
    }

    exec{'restart_otrs_cron':
        command => '/opt/otrs/bin/Cron.sh restart otrs',
        refreshonly => true,
    }
}
