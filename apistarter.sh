#/bin/bash
# v0.2 swe 04/13/2012
# update 6/22/2012
# This works best if run like . ./api-starter
# note the leading dot - that places the variables in your current environment rather than forking a new shell and losing them once that shell closes.
## Clean up temp files here

# Create a 24 hour old file for chache checking tokens.
# Something interesting to try is to change the --date="1 days ago" to --date="26 hours ago" and see if it will give you a new
# token. When I tried, my token was 4 hours old and it gave me back the very same token.
#
tokdate=`date  --date="1 days ago"`
touch -d "$tokdate" token.expire

## Set variables here
## Look for the username, if not found, ask for it. In the future, look for $1 and $2 on the command line and use that instead.

if [  -s .myuser -a -r .myuser ]
	then
		user=`cat .myuser`
	else
		echo -e "Please provide username \c"
		read user
	fi

## Look for the API key, if not found, ask for it

if [  -s .mykey -a -r .mykey ]
	then
		api=`cat .mykey`
	else
		echo -e "Please provide API key \c"
		read api
	fi

# test to see if token.expire is older than our last auth stored in api.out
if [ token.expire -ot api.out ]
        then
                echo "We are using previously stored auth token"
        else
                echo "We need new auth stuff"
curl -D - -H "X-Auth-User: $user" -H "X-Auth-Key: $api"  https://auth.api.rackspacecloud.com/v1.0 | sed -e 's/[[:cntrl:]]//' > api.out
fi

rm token.expire


ret=`grep HTTP/1.1 api.out`
storeurl=`grep X-Storage-Url: api.out | awk '{print $2}'`
tok=`grep X-Auth-Token: api.out | awk '{print $2}'`
storetok=`grep X-Storage-Token: api.out | awk '{print $2}'`
servurl=`grep X-Server-Management-Url api.out | awk '{print $2}'`
cdnurl=`grep X-CDN-Management-Url api.out | awk '{print $2}'`

# You can uncomment below to get a list of your servers
# curl -D - -k -H "X-Auth-Token: $tok " $servurl/servers
