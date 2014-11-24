#!/usr/bin/env perl

use strict ;
use warnings ;

require "calendar_functions.pl" ;

my $agent       = "MyApp/0.1" ;
my $timezone    = "-05:00" ;

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

# get our calendar list data
my $cal_data = get_calendar_list_data( $token, $agent ) ;
if ( $cal_data =~ /^Error/ ) {
    print "$cal_data\n" ;
    exit(1) ;
}

# get calendar ID for Appointments calendar
my $name = "Appointments" ;
my $id = get_calendar_id( $cal_data, $name ) ;
if ( $id =~ /^Error/ ) {
    print "$id\n" ;
    exit(1) ;
}

# create our JSON event structure
my $date        = "2014-11-27" ;
my $starttime   = "18:00" ;
my $endtime     = "19:30" ;
my $title       = "Pick up Sally" ;
my $description = "dont forget the ice-cream" ;
my $json_dates = create_JSON_dates( 
    $date, $starttime, $endtime,
    $timezone, $title, $description ) ;

# get our current bookings for that date/time
my $bookings = get_bookings( $date, $starttime, $endtime,
    $timezone, $id, \%myauth, $agent ) ;
if ( $bookings =~ /^Error/ ) {
    print "$bookings\n" ;
    exit(1) ;
}

# see if time-slot already taken
my $count = is_booked( $bookings ) ;
if ( $count ) {
    print "Sorry - that time is already booked\n" ;
    exit 0 ;
}

# now book the appointment
my $post = create_cal_entry( $json_dates, $token, $id ) ;
if ( $post =~ /^Error/ ) {
    print "$post\n" ;
    exit(1) ;
}
print "Booked appt. status from create_cal_entry() is $post\n" ;
exit 0 ;
