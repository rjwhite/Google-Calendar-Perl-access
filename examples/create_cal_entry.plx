#!/usr/bin/env perl

use strict ;
use warnings ;

require "calendar_functions.pl" ;

my $agent       = "MyApp/0.1" ;
my $timezone    = "-05:00" ;

my $calendar  = '12345678901234567890123456@group.calendar.google.com' ;

my %myauth = (
    'client_secret' => '123456789012345678901234',
    'refresh_token' => '123456789012345678901234567890123456789012345678901234567890123456',
    'client_id'     => '123456789012345678901234567890123456789012345.apps.googleusercontent.com',
    'grant_type'    => 'refresh_token',
) ;

my $token = access_token( \%myauth, $agent ) ;

my $json_dates = create_JSON_dates( 
    "2014-11-27", "11:00", "14:30",
    $timezone, "Pick up Mary", "Dont forget her hat" ) ;

my $post = create_cal_entry( $json_dates, $token, $calendar ) ;
print "response from create_cal_entry() is $post\n" ;
exit 0 ;
