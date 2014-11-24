#!/bin/sh

# Get a refresh token for the Google Calendar service
# Fill in your ClientID and ClientSecret that you got from
# creating a calendar project from:
#    https://code.google.com/apis/console
# and then run this program with no arguments.
# It will print out a URL to go to.  Do that and Accept it.
# It will give you a token.
# Run this program again with that token as a argument.
# It will then print out yuour refresh token.  DON'T lose it.
# It will be used in all your future calls and does not expire.
# This requires the curl program to be installed on your system.

# You need to set these to YOUR ClientID and ClientSecret

ClientID=""
ClientSecret=""


# You shouldn't have to set this stuff, but check that RedirectURI is correct
# you would have got that along with your ClientID and ClientSecret

RedirectURI="urn:ietf:wg:oauth:2.0:oob"
Scope="https://www.googleapis.com/auth/calendar"
OauthURL="https://accounts.google.com/o/oauth2/auth"
TokenURL="https://accounts.google.com/o/oauth2/token"

# arguments to add to OauthURL

response_type="response_type=code"
approval_prompt="approval_prompt=force"
access_type="access_type=offline"
client_id="client_id=$ClientID"
client_secret="client_secret=$ClientSecret"
redirect_uri="redirect_uri=$RedirectURI"
scope="scope=$Scope"
progname=`basename $0`
AuthCode=$1

# build rest of OauthURL
OauthURL="${OauthURL}?$response_type&$approval_prompt&$access_type&$client_id&$redirect_uri&$scope"

if [ x$AuthCode = "x" ]; then
    echo "Go to:"
    echo "   $OauthURL"
    echo ""
    echo "Accept it, and run this script again with the authcode as argumenmt"

    exit 0
else
    code="code=$AuthCode"
    grant_type="grant_type=authorization_code"

    data="${code}&${client_id}&${client_secret}&${redirect_uri}&${grant_type}"

    echo -n "Your refresh token is: "

    curl --silent --data $code --data $client_id --data $client_secret \
     --data $redirect_uri --data $grant_type $TokenURL | \
        grep "refresh_token" | \
        cut -f2 -d: | \
        sed -e 's/^  *//' -e 's/^\"//' -e 's/\"$//'

    exit 0
fi
