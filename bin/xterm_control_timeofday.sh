#!/bin/sh
#
# Script that based on the given latitude and longitude looks up
# sunrise and sunset times and switches between light and dark colors
# using xtermcontrol
#
# Can be used in zsh like:
#
#   case $TERM in
#      xterm*)
#          periodic() { xterm_control_timeofday.sh }
#          PERIOD=300
#          ;;
#   esac
#
# Requires curl (fetch of zone information), xrdb (resources) and
# xtermcontrol for updating the terminal colors.
#
# The following resources should be available (~/.Xdefaults)
#
# pekwm*lightBackground: #fbf8ef
# pekwm*lightForeground: #655370
# pekwm*darkBackground: #292b2e
# pekwm*darkForeground: #b2b2b2
#

# settings
lat='64.618414'
long='21.200051'

# "constants"
TIME_INFO_PATH="$HOME/.time_info"
TIME_INFO_MAX_AGE_S="604800"

UTC_OP=`date '+%z' | sed 's/^\([+-]\).*/\1/'`
UTC_OFFSET=`date '+%z' | sed 's/^[+-]\([0-9][0-9]\).*/\1/'`

clean_time_info_cache()
{
    time_info_updated=`cat "$TIME_INFO_PATH.stamp" 2>/dev/null`
    if test $? -ne 0; then
        time_info_updated='0'
    fi
    now=`pekwm_ctrl -a util timestamp 2>/dev/null`
    if test $? -eq 0; then
        age=$(($now - $time_info_updated))
        if test $age -gt $TIME_INFO_MAX_AGE_S; then
            rm -f "$TIME_INFO_PATH" "$TIME_INFO_PATH.stamp"
        fi
    fi
}

fetch_time_info()
{
    curl -q "https://api.sunrise-sunset.org/json?lat=$lat&lng=$long" \
        | sed 's/.*"\(sunrise\|sunset\)":"\([^"]\+\)".*"\(sunrise\|sunset\)":"\([^"]\+\)".*/time_\1="\2"\ntime_\3="\4"/' \
              > "$TIME_INFO_PATH"
    if test $? -eq 0; then
        echo $now > "$TIME_INFO_PATH.stamp"
    fi
}

get_pekwm_color()
{
    xrdb -query | awk "/pekwm\*${1}:/ { print \$2 }"
}

to_limit_before()
{
    hour=`echo $1 | sed 's/:.*//'`
    echo $(($hour $UTC_OP $UTC_OFFSET))
}

# remove old cache if it exists
clean_time_info_cache
if ! test -e "$TIME_INFO_PATH"; then
    fetch_time_info
fi

. "$TIME_INFO_PATH"
dark_before=`to_limit_before $time_sunrise`
dark_after=`to_limit_before $time_sunset`

h=`date '+%H'`
if test $h -lt $dark_before || test $h -gt $dark_after; then
    mode="dark"
else
    mode="light"
fi

fg=`get_pekwm_color ${mode}Foreground`
bg=`get_pekwm_color ${mode}Background`
if test -z "$fg"; then
    die "missing pekwm*${mode}Foreground resource"
elif test -z "$bg"; then
    die "missing pekwm*${mode}Background resource"
else
    xtermcontrol --fg="$fg" --bg="$bg"
fi
