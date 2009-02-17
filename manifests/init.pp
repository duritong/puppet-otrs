# modules/otrs/manifests/init.pp - manage otrs stuff
# Copyright (C) 2007 admin@immerda.ch
# GPLv3

# modules_dir { "otrs": }

class otrs {
    case $operatingsystem {
        gentoo: { include otrs::gentoo }
        default: { include otrs::base }
    }
}

class otrs::base {
    package{'otrs':
        ensure => installed,
    }
}

class otrs::gentoo inherits otrs::base {
    Package[otrs]{
        category => 'some-category',
    }

    #conf.d file if needed
    # needs module gentoo
    #gentoo::etcconfd { otrs: require => "Package[otrs]", notify => "Service[otrs]"}
}

apache::config::file{ 'otrs.conf': }
