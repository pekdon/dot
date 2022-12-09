#!/bin/sh

error()
{
    echo $@
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
    error "conversion does not match"
fi

# math op
calc_assert_res()
{
    res=`./shell_util calc "$1" "$2" "$3"`
    if test $? -ne 0; then
	error "calc $1 $2 $3 failed: $res"
    fi
    if test $res -ne $4; then
	error "$1 $2 $3 expected $4, got $res"
    fi
    echo "cals: $1 $2 $3 = $4"
}

calc_assert_res 1 + 2 3
calc_assert_res 3 - 4 -1
calc_assert_res 5 '*' 6 30
calc_assert_res 8 / 7 1
calc_assert_res 8 % 7 1
