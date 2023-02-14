#!/bin/sh
#
# Script that looks up location information caching the result for as long
# as the IP addresses of the interfaces are the same.
#

. "$HOME/.pekwm/scripts/config.vars"
. "$HOME/.pekwm/scripts/fetch.sh"

# "constants"
LOCATION_INFO_DIR="$CACHE_DIR/"
LOCATION_INFO_PATH="$LOCATION_INFO_DIR/location_info.vars"

location_info_cache_key_linux()
{
	ip addr | awk '/inet / { print $2 }' | $MD5SUM | sed 's/ .*//'
}

location_info_cache_key_ifconfig()
{
	ifconfig | awk '/inet / { print $2 }' | $MD5SUM | sed 's/ .*//'
}

location_info_cache_key()
{
	if test "x`uname -s`" = "xLinux";  then
		location_info_cache_key_linux
	else
		location_info_cache_key_ifconfig
	fi
}

location_info_fetch()
{
	fetch_stream 'https://api.geoiplookup.net/?query=' \
		> $LOCATION_INFO_PATH.xml
	echo "LOCATION_INFO_CACHE_KEY=\"$1\"" > $LOCATION_INFO_PATH
	$SED 's@.*<latitude>\(.*\)</latitude>.*@LOCATION_INFO_LAT="\1"@' \
		< $LOCATION_INFO_PATH.xml >> $LOCATION_INFO_PATH
	echo >> $LOCATION_INFO_PATH
	$SED 's@.*<longitude>\(.*\)</longitude>.*@LOCATION_INFO_LONG="\1"@' \
		< $LOCATION_INFO_PATH.xml >> $LOCATION_INFO_PATH
	echo >> $LOCATION_INFO_PATH
}

location_info_load()
{
	cache_key=`location_info_cache_key`

	if test -e "$LOCATION_INFO_PATH"; then
		. "$LOCATION_INFO_PATH"
		if test "x$cache_key" != "x$LOCATION_INFO_CACHE_KEY"; then
			location_info_fetch "$cache_key"
			. "$LOCATION_INFO_PATH"
		fi
	else
		mkdir -p "$LOCATION_INFO_DIR"
		location_info_fetch "$cache_key"
		. "$LOCATION_INFO_PATH"
	fi
}

if test "x$1" = "xshow-location-info"; then
	location_info_load
	echo "latitude: $LOCATION_INFO_LAT"
	echo "longitude: $LOCATION_INFO_LONG"
fi
