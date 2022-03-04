#!/bin/sh

# list of keyboard layuouts to toggle between
LAYOUTS="us se no"

# output from xprop:
# _XKB_RULES_NAMES(STRING) = "evdev", "pc105", "us", "", ""
layout=`xprop -root _XKB_RULES_NAMES | sed 's/[,"]//g' | cut -d ' ' -f 5`
next_layout=`echo $LAYOUTS | sed "s/.*$layout \?//" | cut -d ' ' -f 1`
if test "x$next_layout" = "x"; then
	next_layout=`echo $LAYOUTS | cut -d ' ' -f 1`
fi

echo "layout: $layout"
echo "next layout: $next_layout"
setxkbmap $next_layout

