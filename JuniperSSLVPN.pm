package JuniperSSLVPN;

BEGIN { $INC{'JuniperSSLVPN.pm'} ||= __FILE__ }

#===============================================================================
#
#         FILE: JuniperSSLVPN.pm
#
#        USAGE: use JuniperSSLVPN;
#
#  DESCRIPTION: Initial testing parser for Juniper SSL-VPN log file
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: SHIE, Li-Yi <lyshie@mx.nthu.edu.tw>
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 2013/02/27 15:20:00
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(parse_line);

use Date::Parse;
use POSIX qw(strftime);
use Term::ANSIColor qw(:constants);

my $PAT_DATE    = qr/\d{4}\-\d{2}\-\d{2}\s\d{2}:\d{2}:\d{2}/;
my $PAT_IPV4    = qr/\d+\.\d+\.\d+\.\d+/;
my $PAT_JUNIPER = qr/Juniper:\s(.+?)$/;
my $PAT_INFO    = qr/\[($PAT_IPV4)\]\s+\w+::(.+?)\(/
  ;    # match all kinds of account not just email
my $PAT_MSG =
qr/Login (succeeded|failed)(?:(?!Reason:\s|because\s).)+(?:(?:Reason:|because)\s(.+)){0,1}/
  ;    # using look-ahead assertion to match 'Reason: Failed' correctly
my $PAT_ACCESS_DENIED =
qr /Remote address for user (.+?)\/.+? changed from ($PAT_IPV4) to ($PAT_IPV4)\. Access denied\./;
my $PAT_NEGATIVE = qr/(?:failed|denied|ended)/;

my $PAT_TUNNELING =
  qr/VPN Tunneling: Session (started|ended) for user with IP ($PAT_IPV4)/;

sub parse_date {
    my ($date) = @_;

    return ( str2time($date) );
}

sub parse_info {
    my ($info) = @_;
    my ( $ip, $account ) = ( '', '' );

    if ( $info =~ m/^$PAT_INFO/ ) {
        $ip      = $1;
        $account = $2;
    }

    return ( $ip, $account );
}

sub parse_login_msg {
    my ($msg) = @_;
    my ( $result, $reason ) = ( '', '' );

    if ( $msg =~ m/$PAT_MSG/ ) {
        $result = $1;
        $reason = $2 if ( defined($2) );
    }
    elsif ( $msg =~ m/^$PAT_ACCESS_DENIED/ ) {
        $result = "denied";
        $reason = "$2 => $3";
    }

    return ( $result, $reason );
}

sub parse_nc_msg {
    my ($msg) = @_;
    my ( $result, $reason ) = ( '', '' );

    if ( $msg =~ m/$PAT_TUNNELING/ ) {
        $result = $1;
        $reason = $2;
    }

    return ( $result, $reason );
}

sub parse_line {
    my ($str) = @_;
    $str =~ s/[\n\r]//g;

    if ( $str =~ m/$PAT_JUNIPER/ ) {
        my $line = $1;
        my ( $date, $token, $info, $msg ) = split( /\s+\-\s+/, $line );

        my $dt = strftime( "%F %T", localtime( parse_date($date) ) );
        my ( $ip, $account ) = parse_info($info);

        my ( $result, $reason );

        ( $result, $reason ) = parse_login_msg($msg);
        printf(
            "%s [%s%-17s%s] (%-28s) %s%-10s%s %s\n",
            $dt, YELLOW, $ip, RESET, $account,
            ( $result =~ m/$PAT_NEGATIVE/i ? RED : GREEN ),
            $result, RESET, $reason
        ) if ($result);

        ( $result, $reason ) = parse_nc_msg($msg);
        printf(
            "%s [%s%-17s%s] (%-28s) %s%-10s%s %s\n",
            $dt, YELLOW, $ip, RESET, $account,
            ( $result =~ m/$PAT_NEGATIVE/i ? RED : GREEN ),
            $result, RESET, $reason
        ) if ($result);
    }
}

1;
