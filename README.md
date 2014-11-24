Google Calendar Perl access

This contains a library (calendar_functions.pl) that can be used for
command-line access to the new Google Calendar API v3 using Perl.

A example usage program is create_cal_entry_full.plx which uses
most of the functions in the library.

There is also a directory (examples) of short programs testing 
one or more functions.  They expect the library calendar_functions.pl
to be in the current directory where they are run.

The functions in calendar_functions.pl are:
- create_cal_entry()
- create_JSON_dates()
- get_request()
- access_token()
- is_booked()
- get_bookings()
- get_calendar_list_data()
- get_calendar_id()


There is a Bourne shell script, which requires curl to be installed,
to get your 'refresh' token needed.  It is run twice, first with 
no arguments, after you have set up your ClientID and ClientSecret.
After it gives you a URL to visit and accept running, then you
run it again with the token given as the first argument.  Best to
quote that argument in case of any shell meta-characters in it.

To understand more about ClientID, ClientSecret, 'refresh' tokens, etc
for the use of the OAuth2 authentication required by v3 of Google
Calendar, I suggest you check out:
http://cornempire.net/2012/01/08/part-2-oauth2-and-configuring-your-application-with-google/
