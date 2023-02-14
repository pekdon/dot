#!/bin/sh
#
# Script that looks up time information based on the current location.
#

. "$HOME/.pekwm/scripts/config.vars"
. "$HOME/.pekwm/scripts/fetch.sh"
. "$HOME/.pekwm/scripts/location_info.sh"

# "constants"
TIME_INFO_DIR="$CACHE_DIR"
TIME_INFO_PATH="$TIME_INFO_DIR/time_info.vars"
TIME_INFO_MAX_AGE_S="604800"

time_info_cache_clean()
{
	time_info_updated=`cat "$TIME_INFO_PATH.stamp" 2>/dev/null`
	if test "x$time_info_updated" = "x"; then
		time_info_updated='0'
	fi
	now=`shell_util get-unix-time`
	if test $? -eq 0; then
		age=`shell_util calc $now - $time_info_updated`
		if test $age -gt $TIME_INFO_MAX_AGE_S; then
			rm -f "$TIME_INFO_PATH" "$TIME_INFO_PATH.stamp"
		fi
	fi
}

time_info_fetch()
{
	# ensure LOCATION_INFO_LAT and LOCATION_INFO_LONG is set
	location_info_load

	fetch_stream "https://api.sunrise-sunset.org/json?lat=$LOCATION_INFO_LAT&lng=$LOCATION_INFO_LONG" \
		>  "$TIME_INFO_PATH.json"
	if test $? -eq 0; then
		echo $now > "$TIME_INFO_PATH.stamp"
	fi

	$SED 's/.*"sunrise":"\([0-9:]* [AP]M\).*/TIME_INFO_SUNRISE="\1"/' \
		< "$TIME_INFO_PATH.json" > "$TIME_INFO_PATH"
	echo >> $TIME_INFO_PATH
	$SED 's/.*"sunset":"\([0-9:]* [AP]M\).*/TIME_INFO_SUNSET="\1"/' \
		< "$TIME_INFO_PATH.json" >> "$TIME_INFO_PATH"
	echo >> $TIME_INFO_PATH
}

time_info_load()
{
	# remove old cache if it exists
	time_info_cache_clean

	if test -f "$TIME_INFO_PATH"; then
		# cache exists
		true
	else
		mkdir -p "$TIME_INFO_DIR"
		time_info_fetch
	fi

	. $TIME_INFO_PATH
}

if test "x$1" = "xshow-time-info"; then
	time_info_load
	echo "sunrise: $TIME_INFO_SUNRISE"
	echo "sunset: $TIME_INFO_SUNSET"
fi
