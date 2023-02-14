#!/bin/sh
#
# Wrapper for curl, ftp and wget depending on what is available.
#

FETCH_COMMAND=""
FETCH_COMMAND_ARGS_FILE=""
FETCH_COMMAND_ARGS_STREAM=""

fetch_init_command_ftp()
{
	FETCH_COMMAND="$1"
	FETCH_COMMAND_ARGS_FILE="-V -o"
	FETCH_COMMAND_ARGS_STREAM="-V -o -"
}

fetch_init()
{
	# OpenBSD and NetBSD ftp come with http(s) support, fast forward
	# and use it.
	case `uname -s` in
		OpenBSD|NetBSD)
			fetch_init_command_ftp "/usr/bin/ftp"
			return
			;;
		*)
		    ;;
	esac

	FETCH_COMMAND=`which curl 2>/dev/null | /usr/bin/grep '^/'`
	if test "x$FETCH_COMMAND" != "x"; then
		FETCH_COMMAND_type="curl"
		FETCH_COMMAND_ARGS_FILE="-L -s -o"
		FETCH_COMMAND_ARGS_STREAM="-L -s"
		return
	fi

	FETCH_COMMAND=`which wget 2>/dev/null | /usr/bin/grep '^/'`
	if test "x$FETCH_COMMAND" != "x"; then
		FETCH_COMMAND_ARGS_FILE="-q -O"
		FETCH_COMMAND_ARGS_FILE="-q -O -"
		return
	fi

	FETCH_COMMAND=`which ftp 2>/dev/null | /usr/bin/grep '^/'`
	if test "x$FETCH_COMMAND" != "x"; then
		$FETCH_COMMAND -h 2>&1 | /usr/bin/grep -q http
		if $? -eq 0; then
			fetch_init_command_ftp "$FETCH_COMMAND"
		else
			FETCH_COMMAND=""
		fi
	fi
}

# fetch_stream url
fetch_stream()
{
	"$FETCH_COMMAND" $FETCH_COMMAND_ARGS_STREAM "$1"
}

# fetch_file url local-path
fetch_file()
{
	"$FETCH_COMMAND" $FETCH_COMMAND_ARGS_FILE "$2" "$1"
}

if test "x$FETCH_COMMAND" = "x"; then
	fetch_init
	if test "x$FETCH_COMMAND" = "x"; then
		error "no supported HTTP client (curl, wget, BSD ftp)"
	fi
fi

if test "x$1" = "xshow-fetch"; then
	echo "fetch_command: $FETCH_COMMAND"
	echo "fetch_command_args_file: $FETCH_COMMAND_ARGS_FILE"
	echo "fetch_command_args_stream: $FETCH_COMMAND_ARGS_STREAM"
fi
