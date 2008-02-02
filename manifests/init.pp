# modules/otrs2/manifests/init.pp - manage skeleton stuff
# Copyright (C) 2007 admin@immerda.ch
#

# modules_dir { "otrs2": }

class otrs2 {

    package{otrs2: ensure => installed, }

}
