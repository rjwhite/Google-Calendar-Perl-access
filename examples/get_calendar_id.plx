#!/usr/bin/env perl

# get the calendar ID for our "Appointments" calendar

use strict ;
use warnings ;

require "calendar_functions.pl" ;

my $agent     = "MyApp/0.1" ;

my %myauth = (
    'client_secret' => '123456789012345678901234',
    'refresh_token' => '123456789012345678901234567890123456789012345678901234567890123456',
    'client_id'     => '123456789012345678901234567890123456789012345.apps.googleusercontent.com',
    'grant_type'    => 'refresh_token',
) ;
# get a token
my $token = access_token( \%myauth, $agent ) ;
if ( $token =~ /^Error/ ) {
    print "$token\n" ;
    exit(1) ;
}

# get our calendar data
my $cal_data = get_calendar_list_data( $token, $agent ) ;
if ( $token =~ /^Error/ ) {
    print "$token\n" ;
    exit(1) ;
}

# get calendar ID
my $name = "Appointments" ;
my $id = get_calendar_id( $cal_data, $name ) ;
print "ID for $name = $id\n" ;

exit 0 ;
