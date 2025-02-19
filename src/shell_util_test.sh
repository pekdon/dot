#!/bin/sh

test_error()
{
	echo "ERROR: $@"
	exit 1
}

# time/date functions
fmt='%Y-%m-%d %H:%M:%S'

now=`./shell_util get-unix-time`
formatted=`./shell_util format-unix-time $now "$fmt" local`
to_unix=`./shell_util to-unix-time "$formatted" "$fmt" local`

echo "get-unix-time: $now"
echo "format-unix-time: $formatted"
echo "to-unix-time: $to_unix"

if test "$now" != "$to_unix"; then
	test_error "conversion does not match"
fi

# math op
calc_assert_res()
{
	res=`./shell_util calc "$1" "$2" "$3"`
	if test $? -ne 0; then
		test_error "calc $1 $2 $3 failed: $res"
	fi
	if test $res -ne $4; then
		test_error "$1 $2 $3 expected $4, got $res"
	fi
	echo "cals: $1 $2 $3 = $4"
}

calc_assert_res 1 + 2 3
calc_assert_res 3 - 4 -1
calc_assert_res 5 '*' 6 30
calc_assert_res 8 / 7 1
calc_assert_res 8 % 7 1

# expandpath
expandpath_assert_res()
{
	res=`./shell_util expandpath "$2" 2>&1`
	if test $? -ne $1; then
		test_error "expandpath $2 expected $1, got $?"
	fi
	if test "x$res" != "x$3"; then
		test_error "expandpath $2 expected $3, got $res"
	fi
	echo "expandpath $2 = $res"
}
expandpath_assert_res 0 "./shell_util" "$PWD/shell_util"
expandpath_assert_res 0 "$PWD/extra/../test" "$PWD/test"
expandpath_assert_res 0 "/missing/path" "/missing/path"
expandpath_assert_res 1 "/../../" "expandpath: empty path"

# realpath
realpath_assert_res()
{
	res=`./shell_util realpath "$2" 2>&1`
	if test $? -ne $1; then
		test_error "realpath $2 expected $1, got $?"
	fi
	if test "x$res" != "x$3"; then
		test_error "realpath $2 expected $3, got $res"
	fi
	echo "realpath $2 = $res"
}

realpath_assert_res 0 "./shell_util" "$PWD/shell_util"
realpath_assert_res 0 "$PWD/shell_util" "$PWD/shell_util"
realpath_assert_res 1 "/missing/path" "realpath: No such file or directory"
