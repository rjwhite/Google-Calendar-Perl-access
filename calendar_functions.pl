#!/usr/bin/env perl

# A bunch of functions for use with the Google Calendar v3 API using REST
#
# Copyright 2014 RJ White
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# RJ White
# rj@moxad.com
# Nov 2014

use strict ;
use warnings ;
use LWP::UserAgent;
use JSON ;
use URI::Encode qw(uri_encode uri_decode);

my $C_ERROR = "Error:" ;

# create a calendar entry
#
# Inputs:
#   1:  JSON structure of dates/times - from create_JSON_dates()
#   2:  access token - from access_token()
#   3:  calendar ID
#   4:  agent - can be undefined or empty string
# Output:
#   status              if ok
#   $C_ERROR: msg       if not ok

sub create_cal_entry {
    my $json_dates  = shift ;
    my $token       = shift ;
    my $cal_id      = shift ;
    my $agent       = shift ;

    my $i_am = "create_cal_entry()" ;
    if (( not defined( $json_dates )) or ( $json_dates eq "" )) {
        return( "${C_ERROR} $i_am: JSON dates undefined or empty string (Arg 1)" ) ;
    }
    if (( not defined( $token )) or ( $token eq "" )) {
        return( "${C_ERROR} $i_am: token undefined or empty string (Arg 2)" ) ;
    }
    if (( not defined( $cal_id )) or ( $cal_id eq "" )) {
        return( "${C_ERROR} $i_am: Calendar ID undefined or empty string (Arg 3)" ) ;
    }
    if (( not defined( $agent )) or ( $agent eq "" )) {
        $agent = "MyApp/0.1" ;
    }

    # Note:
    # examples in Php I came across show that the URL need args added of
    #       "pp=1&key=$api_key" ;
    # added, but I found neither were needed to make it work.
    # So they are commented out below.  
    # Also notice I am no longer passing in the $api_key in  this function.

    # my $args = "pp=1&key=$api_key" ;
    my $args = "" ;

    my $base_url = 'https://www.googleapis.com/calendar/v3/calendars/' ;
    my $url      = "${base_url}${cal_id}/events?${args}" ;

    my $ua = LWP::UserAgent->new ;
    $ua->agent( $agent ) ;
    $ua->default_header( Authorization => 'Bearer ' . $token ) ;

    my $req = HTTP::Request->new( POST => $url ) ;
    $req->content_type( 'application/json' ) ;

    $req->content( $json_dates ) ;

    # Pass request to the user agent and get a response back
    my $res  = $ua->request( $req ) ;
    my $code = $res->code ;
    my $msg  = $res->message ;

    # Check the outcome of the response
    if ( $res->is_success ) {
        if ( not defined(  $res->content )) {
            return( "${C_ERROR} $i_am: Content not defined" ) ;
        }

        if ( $res->content =~ /^{/ ) {
            # seems to be a JSON string.
            my $r = from_json( $res->content ) ;
            my $status = $r->{ 'status' } ;
            return( $status ) ;
        } else {
            # must be a ordinary string
            return( "success" ) ;       # shouldn't happen?
        }
    } elsif ( $res->is_error ) {
        return( "${C_ERROR} $i_am: $msg ($code)" ) ;
    } else {
        return( "${C_ERROR} $i_am: unknown state: $msg ($code)" ) ;
    }
}


# Create a JSON structure of dates required for input to create_cal_entry().
# The date is YYYY-MM-DD format, and times are passed to the function in
# HH:mm format. They are then padded with the seconds and timezone.
#
# Inputs:
#   1:  date:           YYYY-MM-DD  	eg: 2014-12-09
#   2:  start date:     HH:mm       	eg: 12:00
#   3:  end-date:       HH:mm       	eg: 14:30
#   4:  timezone:       +/-DD:DD    	eg: -05:00
#   5:  title:          string      	eg: "Pick up Johnny"
#   6:  description:    string      	eg: "dont forget the ice-cream"
# Output:
#   JSON string

sub create_JSON_dates {
    my $date        = shift ;
    my $starttime   = shift ;
    my $endtime     = shift ;
    my $timezone    = shift ;
    my $title       = shift ;
    my $description = shift ;
   
    my $i_am = "create_JSON_dates()" ;
    # Argument sanity checking
    if (( not defined( $date )) or ( $date eq "" )) {
        return( "${C_ERROR} $i_am: No date (Arg 1) given" ) ;
    }
    if (( not defined( $starttime )) or ( $starttime eq "" )) {
        return( "${C_ERROR} $i_am: No start-time (Arg 2) given" ) ;
    }
    if (( not defined( $endtime )) or ( $endtime eq "" )) {
        return( "${C_ERROR} $i_am: No end-time (Arg 3) given" ) ;
    }
    if (( not defined( $timezone )) or ( $timezone eq "" )) {
        $timezone = "-05:00" ;
    }
    if (( not defined( $title )) or ( $title eq "" )) {
        $title = "unknown" ;
    }
    if (( not defined( $description )) or ( $description eq "" )) {
        $description = "unknown" ;
    }

    my $str = << "JSON" ;
{
    start: {
        dateTime: "${date}T${starttime}:00.000${timezone}"
    },
    end: {
        dateTime: "${date}T${endtime}:00.000${timezone}"
    },
    "summary": "$title",
    "description": "$description",
    "SingleEvents": 1
}
JSON
    return( $str ) ;
}



# Send a GET HTTP request.
# Can get a ordinary web-page if $token is empty string
#
# Input:
#   access-token:   get with access_token()
#   URL:            http://what.ever
# Output:
#   string          if ok
#   $C_ERROR: msg   if not ok

sub get_request {
    my $token   = shift ;
    my $url     = shift ;
    my $agent   = shift ;

    my $i_am = "get_request()" ;

    if (( not defined( $url )) or ( $url eq "" )) {
        return( "${C_ERROR} $i_am: URL (Arg 1) is undefined or empty string" );
    }
    if (( not defined( $agent )) or ( $agent eq "" )) {
        $agent = "MyApp/0.1" ;
    }

    my $ua = LWP::UserAgent->new ;
    $ua->agent( $agent ) ;
    if ( defined( $token ) and ( $token ne "" )) {
        $ua->default_header( Authorization => 'Bearer ' . $token ) ;
    }

    # Create a request
    my $req = HTTP::Request->new( GET => $url ) ;

    # Pass request to the user agent and get a response back
    my $res  = $ua->request( $req );
    my $code = $res->code ;
    my $msg  = $res->message ;

    # Check the outcome of the response
    if ( $res->is_success ) {
        if ( not defined(  $res->content )) {
            return( "${C_ERROR} $i_am: return content not defined for $url" ) ;
        }
        if ( $res->content eq "" ) {
            return( "${C_ERROR} $i_am: return content empty string for $url" ) ;
        }
        return( $res->content ) ;
    } elsif ( $res->is_error ) {
        return( "${C_ERROR} $i_am: $msg ($code) for $url" ) ;
    } else {
        return( "${C_ERROR} $i_am: unknown state: $msg ($code) for $url" ) ;
    }
}


# Get an access token using OAuthe2 previously set up.
#
# Inputs:
#   reference to hash of access data
#   agent
# Output:
#   string          if ok
#   $C_ERROR: msg   if not ok

sub access_token {
    my $data_ref = shift ;
    my $agent    = shift ;

    my $i_am = "access_token()" ;
    if (( ref( $data_ref ) eq "" ) or ( ref( $data_ref ) ne "HASH" )) {
        return( "${C_ERROR} $i_am: Arg 1 is not a HASH reference" ) ;
    }
    if (( not defined( $agent )) or ( $agent eq "" )) {
        $agent = "MyApp/0.1" ;
    }

    my $data = "" ;

    # build the list of arguments
    foreach my $key ( keys( %{$data_ref})) {
        my $value = ${$data_ref}{ $key} ;
        $data .= "${key}=${value}&" ;
    }
    chop( $data ) ;     # remove trailing '&'

    my $tokenURL = 'https://accounts.google.com/o/oauth2/token' ;

    my $ua = LWP::UserAgent->new;
    $ua->agent( $agent );

    # Create a request
    my $req = HTTP::Request->new( POST => $tokenURL ) ;
    $req->content_type( 'application/x-www-form-urlencoded' );
    $req->content( $data ) ;

    # Pass request to the user agent and get a response back
    my $res = $ua->request( $req );

    # Check the outcome of the response
    if ( $res->is_success ) {
        my $ref = from_json( $res->content ) ;
        my $access_token = ${$ref}{ 'access_token' } ;
        return( $access_token ) ;
    } else {
        return( "${C_ERROR} $i_am: $res->status_line" ) ;
    }
}


# See if a time slot is already booked
#
# Inputs:
#   bookings string - returned by get_bookings()
# Output:
#   count of bookings.  0 = no bookings
#   $C_ERROR: msg       if not ok

sub is_booked {
    my $bookings = shift ;

    my $i_am = "is_booked()" ;
    if (( not defined( $bookings )) or ( $bookings eq "" )) {
        return( "${C_ERROR} $i_am: bookings (Arg 1) is undefined or empty string" ) ;
    }

    if ( $bookings =~ /^{/ ) {
        # seems to be a JSON string.
        my $ref = from_json( $bookings ) ;
        my $items_ref = ${$ref}{ "items" } ;
        if ( not defined( $items_ref )) {
            return( "${C_ERROR} $i_am: did not find items in bookings" ) ;
        }
        my $num = 0 ;
        foreach my $array_ref ( @{$items_ref} ) {
            $num++ ;
        }
        return( $num ) ;
    } else {
        return( "${C_ERROR} $i_am: did not find JSON string to parse" ) ;
    }
}


# Get bookings
#
# Inputs:
#   1:  date:               YYYY-MM-DD  eg: 2014-12-09
#   2:  start date:         HH:mm       eg: 12:00
#   3:  end-date:           HH:mm       eg: 14:30
#   4:  timezone:           +/-DD:DD    eg: -05:00
#   5:  calendar-ID
#   6:  reference to hash of authentication data
#   7:  agent - can be empty string
#   8:  (optional) string of comma separated fields we want
# Output:
#   JSON string of bookings

sub get_bookings {
    my $date        = shift ;
    my $start_time  = shift ;
    my $end_time    = shift ;
    my $timezone    = shift ;
    my $cal_id      = shift ;
    my $auth_ref    = shift ;
    my $agent       = shift ;
    my $fields      = shift ;

    my $i_am   = "get_bookings()" ;

    # argument sanity checking.  These are all scalars
    my %args_check = (
        "Date (Arg 1)"          => \$date,
        "Start time (Arg 2)"    => \$start_time,
        "End time (Arg 3)"      => \$end_time,
        "timezone (Arg 4)"      => \$timezone,
        "calendar ID (Arg 5)"   => \$cal_id,
    ) ;
    foreach my $err( keys( %args_check )) {
        my $addr = $args_check{ $err } ;
        if ( not defined( ${$addr} )) {
            return( "${C_ERROR} $i_am: $err is undefined" ) ;
        }
        if ( ${$addr} eq "" ) {
            return( "${C_ERROR} $i_am: $err is a empty string" ) ;
        }
    }

    if (( ref( $auth_ref ) eq "" ) or ( ref( $auth_ref ) ne "HASH" )) {
        return( "${C_ERROR} $i_am: Arg 6 is not a HASH reference" ) ;
    }

    if ( not defined( $fields )) {
        $fields = "" ;
    }

    my $request = "https://www.googleapis.com/calendar/v3/calendars/" ;
    my $start   = $date . 'T' . $start_time . ":00.000${timezone}";
    my $end     = $date . 'T' . $end_time . ":00.000${timezone}";

    # build up request

    $request .= uri_encode($cal_id, {encode_reserved => 1}) . '/events?' ;
    $request .= 'timeMax=' . uri_encode($end, {encode_reserved => 1}) ;
    $request .= '&timeMin=' . uri_encode($start, {encode_reserved => 1}) ;
    $request .= '&singleEvents=true' ;

    # if user gave a restricted bumch of fields, provide them
    if ( $fields ne "" ) {
        $request .= '&fields=items(' . $fields . ')' ;
    }

    my $token = access_token( $auth_ref, $agent );
    if ( $token =~ /^${C_ERROR}/ ) {
        return( $token ) ;
    }

    return( get_request( $token, $request, $agent )) ;
}


# get JSON data of our calendars
#
# Input:
#   access-token -  get with access_token()
#   agent - can be empyty string
# Output:
#   string          if ok
#   $C_ERROR: msg   if not ok

sub get_calendar_list_data {
    my $token   = shift ;
    my $agent   = shift ;

    my $url = "https://www.googleapis.com/calendar/v3/users/me/calendarList" ;

    my $str = get_request( $token, $url, $agent ) ;

    return( $str ) ;
}

# get a calendar ID
#
# Inputs:
#   1:  calendar data - from get_calendar_list()
#   2:  name of calendar.    eg: 'Appointments'
# Output:
#   ID                  if ok
#   $C_ERROR: msg       if not ok

sub get_calendar_id {
    my $cal_data    = shift ;
    my $name        = shift ;

    my $i_am = "get_calendar_id()" ;

    if (( not defined( $name )) or ( $name eq "" )) {
        return( "${C_ERROR} $i_am: name (Arg 1) is undefined or empty string" ) ;
    }
    if ( $cal_data !~ /^{/ ) {
        return( "${C_ERROR} $i_am: Calendar data (Arg 2) is not a JSON string" ) ;
    }

    my $ref = from_json( $cal_data ) ;
    my $items_ref = ${$ref}{ "items" } ;
    if ( not defined( $items_ref )) {
        return( "${C_ERROR} $i_am: missing \'items\' in JSON calendar data" ) ;
    }
    my $num   = 0 ;
    my $found = 0 ;
    my $id    = "" ;
    foreach my $array_ref ( @{$items_ref} ) {
        $num++ ;
        my $summary = ${$array_ref}{ 'summary' } ;
        if ( $summary =~ /$name/i ) {
            $found++ ;
            $id = ${$array_ref}{ 'id' } ;
            if (( not defined( $id )) or ( $id eq "" )) {
                my $err = "calendar ID undefined or empty string for \'$name\'" ;
                return( "${C_ERROR} $i_am: $err" ) ;
            }
            last ;
        }
    }
    if ( $num == 0 ) {
        return( "${C_ERROR} $i_am: No calendar items found" ) ;
    }
    if ( $found == 0 ) {
        return( "${C_ERROR} $i_am: No calendar found for \'$name\'" ) ;
    }
    return( $id ) ;
}

1;
