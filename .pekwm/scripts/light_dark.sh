#!/bin/sh
#
# Script that based on the given latitude and longitude looks up
# sunrise and sunset times and switches between light and dark colors
# by writing to open ptys and updating Xresources .
#
# Requires curl (fetch of zone information) and pekwm_ctrl (resources)
#
# The following resources should be available (~/.Xdefaults)
#
# pekwm*lightBackground: #fbf8ef
# pekwm*lightForeground: #655370
# pekwm*darkBackground: #292b2e
# pekwm*darkForeground: #b2b2b2
#

. "$HOME/.pekwm/scripts/config.vars"
. "$HOME/.pekwm/scripts/time_info.sh"

LIGHT_DARK_XRESOURCES_PATH="$CACHE_DIR/light_dark.xresources"
LIGHT_DARK_MODE_PATH="$CACHE_DIR/light_dark.mode"

error()
{
	echo "$@"
	exit 1
}

get_pekwm_color()
{
	pekwm_ctrl -g "pekwm*${1}"
}

find_ttys()
{
	case $OS in
		Darwin)
			ls dev/ttys00[0-9]*
			;;
		Linux)
			ls /dev/pts/[0-9]*
			;;
		# OpenBSD)
		# 	find /dev -name 'ttyp*' -maxdepth 1 -user $USER
		# 	;;
		*)
			;;
	esac
}

# no DISPLAY set, skip background control
if test -z "$DISPLAY"; then
	exit 0
fi

time_info_load
dark_before_utc=`shell_util to-unix-time "$TIME_INFO_SUNRISE" '%I:%M:%S %p' utc`
dark_after_utc=`shell_util to-unix-time "$TIME_INFO_SUNSET" '%I:%M:%S %p' utc`

# get time of day using start of day timestamp vs current timestamp
now=`shell_util get-unix-time`
day_start_str=`shell_util format-unix-time $now '%Y-%m-%d 00:00:00'`
day_start=`shell_util to-unix-time "$day_start_str" '%Y-%m-%d %H:%M:%S'`
tod=`shell_util calc $now - $day_start`
if test $tod -lt $dark_before_utc || test $tod -gt $dark_after_utc; then
	mode="dark"
else
	mode="light"
fi

if test "x$1" = "xforce-light-dark"; then
	# force mode
	true
elif test -e "$LIGHT_DARK_MODE_PATH"; then
	# if already set to the current mode, do not waste resources updating
	# the mode again
	if test "x`cat "$LIGHT_DARK_MODE_PATH"`" = "x$mode"; then
		exit 0
	fi
fi

fg=`get_pekwm_color ${mode}Foreground`
bg=`get_pekwm_color ${mode}Background`
if test -z "$fg"; then
	error "missing pekwm*${mode}Foreground resource"
elif test -z "$bg"; then
	error "missing pekwm*${mode}Background resource"
else
	ttys=`find_ttys`

	# update X resources
	cat > "$LIGHT_DARK_XRESOURCES_PATH" <<EOF
*background: ${bg}
*foreground: ${fg}
EOF
	xrdb -merge "$LIGHT_DARK_XRESOURCES_PATH"
	
	# update TTYs terminals
	for tty in $ttys; do
		if test -e $tty; then
			echo -n "\033]10;${fg}\033\\" >> $tty
			echo -n "\033]11;${bg}\033\\" >> $tty
		fi
	done

	echo "$mode" > "$LIGHT_DARK_MODE_PATH"
fi
