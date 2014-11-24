#!/usr/bin/env perl

use strict ;
use warnings ;
use JSON ;

require "calendar_functions.pl" ;

my $agent     = "MyApp/0.1" ;
my $timezone  = "-05:00" ;

my $calendar  = '12345678901234567890123456@group.calendar.google.com' ;

my %myauth = (
    'client_secret' => '123456789012345678901234',
    'refresh_token' => '123456789012345678901234567890123456789012345678901234567890123456',
    'client_id'     => '123456789012345678901234567890123456789012345.apps.googleusercontent.com',
    'grant_type'    => 'refresh_token',
) ;
my $date       = "2014-11-23" ;
my $starttime  = "10:00" ;
my $endtime    = "18:30" ;
my $bookings = get_bookings( $date, $starttime, $endtime,
    $timezone, $calendar, \%myauth, $agent ) ;
if ( $bookings =~ /^Error/ ) {
    print "$bookings\n" ;
    exit(1) ;
}

print "Bookings:\n" ;
if ( $bookings =~ /^{/ ) {
    # seems to be a JSON string.
    my $ref = from_json( $bookings ) ;
    my $items_ref = ${$ref}{ "items" } ;
    if ( not defined( $items_ref )) {
        print "Error: Did not find items in bookings\n" ;
        exit(1) ;
    }
    my $num = 0 ;
    foreach my $array_ref ( @{$items_ref} ) {
        $num++ ;
        my $start = ${$array_ref}{ 'start' }{ 'dateTime' } ;
        my $end   = ${$array_ref}{ 'end' }{ 'dateTime' } ;
        print "\t($num): start: $start  /  end: $end\n" ;
    }
}

my $count = is_booked( $bookings ) ;
print "count of bookings  = $count\n" ;

exit 0 ;
