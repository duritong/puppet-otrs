# --
# Kernel/Config.pm - Config file for OTRS kernel
# Copyright (C) 2001-2008 OTRS AG, http://otrs.org/
# --
# $Id: Config.pm.dist,v 1.20 2008/03/07 16:50:44 martin Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl-2.0.txt.
# --
#  Note:
#
#  -->> OTRS does have a lot of config settings. For more settings
#       (Notifications, Ticket::ViewAccelerator, Ticket::NumberGenerator,
#       LDAP, PostMaster, Session, Preferences, ...) see
#       Kernel/Config/Defaults.pm and copy your wanted lines into "this"
#       config file. This file will not be changed on update!
#
# --

package Kernel::Config;

sub Load {
    my $Self = shift;
    # ---------------------------------------------------- #
    # ---------------------------------------------------- #
    #                                                      #
    #         Start of your own config options!!!          #
    #                                                      #
    # ---------------------------------------------------- #
    # ---------------------------------------------------- #

    # ---------------------------------------------------- #
    # database settings                                    #
    # ---------------------------------------------------- #
    # DatabaseHost
    # (The database host.)
    $Self->{'DatabaseHost'} = 'localhost';
    # Database
    # (The database name.)
    $Self->{'Database'} = 'database';
    # DatabaseUser
    # (The database user.)
    $Self->{'DatabaseUser'} = 'root';
    # DatabasePw
    # (The password of database user. You also can use bin/CryptPassword.pl
    # for crypted passwords.)
    $Self->{'DatabasePw'} = '';
    # DatabaseDSN
    # (The database DSN for MySQL ==> more: "man DBD::mysql")
    $Self->{DatabaseDSN} = "DBI:mysql:database=$Self->{Database};host=$Self->{DatabaseHost};";

    # (The database DSN for PostgreSQL ==> more: "man DBD::Pg")
    # if you want to use a local socket connection
#    $Self->{DatabaseDSN} = "DBI:Pg:dbname=$Self->{Database};";
    # if you want to use a tcpip connection
#    $Self->{DatabaseDSN} = "DBI:Pg:dbname=$Self->{Database};host=$Self->{DatabaseHost};";

    # ---------------------------------------------------- #
    # fs root directory
    # ---------------------------------------------------- #
    $Self->{Home} = '/opt/otrs';

    # ---------------------------------------------------- #
    # insert your own config settings "here"               #
    # config settings taken from Kernel/Config/Defaults.pm #
    # ---------------------------------------------------- #
    # $Self->{SessionUseCookie} = 0;
    # $Self->{'CheckMXRecord'} = 1;

    # ---------------------------------------------------- #

    # ---------------------------------------------------- #
    # data inserted by installer                           #
    # ---------------------------------------------------- #
    # $DIBI$
    $Self->{'SystemID'} = 10;
    $Self->{'SecureMode'} = 1;
    $Self->{'Organization'} = 'Example Organisation';
    $Self->{'LogModule::LogFile'} = '/tmp/otrs.log';
    $Self->{'LogModule'} = 'Kernel::System::Log::SysLog';
    $Self->{'FQDN'} = 'otrs.example.com';
    $Self->{'DefaultLanguage'} = 'en';
    $Self->{'AdminEmail'} = 'root@example.com';
    $Self->{'DefaultCharset'} = 'utf-8';

    # ---------------------------------------------------- #
    # ---------------------------------------------------- #
    #                                                      #
    #           End of your own config options!!!          #
    #                                                      #
    # ---------------------------------------------------- #
    # ---------------------------------------------------- #
}

# ---------------------------------------------------- #
# needed system stuff (don't edit this)                #
# ---------------------------------------------------- #
use strict;
use warnings;

use vars qw(@ISA $VERSION);
use Kernel::Config::Defaults;
push (@ISA, 'Kernel::Config::Defaults');

use vars qw(@ISA $VERSION);
$VERSION = qw($Revision: 1.20 $)[1];

# -----------------------------------------------------#

1;
