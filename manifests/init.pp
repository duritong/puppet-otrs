#
# otrs module
#
# Copyright 2008, Puzzle ITC
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#

class otrs {
    include otrs::base
}

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
        source => [ "puppet://$server/files/otrs/sysconfig/${fqdn}/otrs",
                    "puppet://$server/files/otrs/sysconfig/otrs",
                    "puppet://$server/otrs/sysconfig/${operatingsystem}/otrs",
                    "puppet://$server/otrs/sysconfig/otrs" ],
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
        source => [ "puppet://$server/files/otrs/httpd/${fqdn}/otrs.conf",
                    "puppet://$server/files/otrs/httpd/otrs.conf",
                    "puppet://$server/otrs/httpd/otrs.conf" ],
        require => [ Package['otrs'], Package['apache'] ],
        notify => Service['apache'],
        owner => root, group => 0, mode => 0644;
    }

    file{'/opt/otrs/Kernel/Config.pm':
        source => [ "puppet://$server/files/otrs/config/${fqdn}/Config.pm",
                    "puppet://$server/files/otrs/config/Config.pm",
                    "puppet://$server/otrs/config/Config.pm" ],
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
