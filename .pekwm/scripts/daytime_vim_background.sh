#!/bin/sh

if test "x$VIM" = "x"; then
	VIM="gvim"
fi

if test "x$PEKWM_SYS_TIMEOFDAY" = "x"; then
	echo "\$PEKWM_SYS_TIMEOFDAY not set"
	exit 1;
elif test "x$PEKWM_SYS_TIMEOFDAY" = "xday"; then
	bg="light"
else
	bg="dark"
fi

for server in `$VIM --serverlist | sed 1d`; do
	$VIM --servername $server --remote-send ":set background=$bg<Esc>"
done
