#!/usr/bin/env perl

use strict ;
use warnings ;

require "calendar_functions.pl" ;

my $token = "" ;
my $page = "http://www.moxad.com" ;
my $output = get_request( $token, $page, "Some agent" ) ;
print "$output \n" ;
exit 0 ;
