#!/bin/sh

# list of keyboard layuouts to toggle between
LAYOUTS="us se"

# output from xprop:
# _XKB_RULES_NAMES(STRING) = "evdev", "pc105", "us", "", ""
if test "x$1" != "xfirst"; then
    layout=`xprop -root _XKB_RULES_NAMES | sed 's/[,"]//g' | cut -d ' ' -f 5`
    next_layout=`echo $LAYOUTS | sed "s/.*$layout \{0,1\}//" | cut -d ' ' -f 1`
fi

if test "x$next_layout" = "x"; then
	next_layout=`echo $LAYOUTS | cut -d ' ' -f 1`
fi

echo "layout: $layout"
echo "next layout: $next_layout"
setxkbmap $next_layout

