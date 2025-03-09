#!/bin/sh

KNOWN_PLAYERS="cmus"
KNOWN_VOL="pulse"

music_cmus_play()
{
	cmus-remote -p
}

music_cmus_stop()
{
	cmus-remote -s
}

music_cmus_next()
{
	cmus-remote -n
}

music_cmus_prev()
{
	cmus-remote -p
}


vol_pulse_up()
{
	pactl -- set-sink-volume 0 '+10%'
}

vol_pulse_down()
{
	pactl -- set-sink-volume 0 '-10%'
}

vol_pulse_mute()
{
	pactl -- set-sink-volume 0 0
}

usage()
{
	cat <<EOF
usage: $0 [-hq] [play|pause|stop|next|prev|vup|vdown|vmute]
EOF
	exit $0
}

opt_quiet="no"
while `test "x$1" != "x"`; do
	case $1 in
		"-h")
			usage 0
			;;
		"-q")
			opt_quiet="yes"
			shift
			;;
		*)
			break
			;;
	esac
done

MUSIC_CTRL=`xrdb -get pekwm.audio.player`
VOL_CTRL=`xrdb -get pekwm.audio.control`
if test "x$MUSIC_CTRL" = "x" -o "x$VOL_CTRL" = "x"; then
	if test "x$opt_quiet" = "xno"; then
		pekwm_dialog -D no-titlebar -t pekwm_audio_ctrl.sh \
			"ERROR: pekwm.audio.player and pekwm.audio.control" \
			"not set or empty\n\nSet pekwm.audio.player to one" \
			"of: $KNOWN_PLAYERS\nSet pekwm.audio.control to one" \
			"of: $KNOWN_VOL"
	fi
	exit 0
fi

# FIXME: validate and initialize volume control settings

case $1 in
	play)
		cmd="music_${MUSIC_CTRL}_play"
		;;
	pause)
		cmd="music_${MUSIC_CTRL}_pause"
		;;
	stop)
		cmd="music_${MUSIC_CTRL}_stop"
		;;
	next)
		cmd="music_${MUSIC_CTRL}_next"
		;;
	prev)
		cmd="music_${MUSIC_CTRL}_prev"
		;;
	vup)
		cmd="vol_${VOL_CTRL}_up"
		;;
	vdown)
		cmd="vol_${VOL_CTRL}_down"
		;;
	vmute)
		cmd="vol_${VOL_CTRL}_mute"
		;;
	*)
		usage 1
		;;
esac

$cmd
