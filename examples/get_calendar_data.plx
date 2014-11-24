#!/usr/bin/env perl

use strict ;
use warnings ;

require "calendar_functions.pl" ;

my $agent = "MyApp/0.1" ;

my %myauth = (
    'client_secret' => '123456789012345678901234',
    'refresh_token' => '123456789012345678901234567890123456789012345678901234567890123456',
    'client_id'     => '123456789012345678901234567890123456789012345.apps.googleusercontent.com',
    'grant_type'    => 'refresh_token',
) ;
my $token = access_token( \%myauth, $agent ) ;

my $list = get_calendar_list_data( $token, $agent ) ;
print "$list\n" ;

exit 0 ;
