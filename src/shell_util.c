#define _GNU_SOURCE
#define _XOPEN_SOURCE

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

static bool str_to_ll(const char *str, int64_t *val_ret)
{
	char *endptr;
	int64_t val = strtoll(str, &endptr, 10);
	if (endptr == NULL || *endptr != '\0') {
		fprintf(stderr, "failed to parse: %s (rest %s)\n",
			str, endptr ? endptr : "");
		return false;
	}
	*val_ret = val;
	return true;
}

/**
 * Convert time_str in the provided format into a UNIX timestamp then
 * print on stdout.
 */
static int to_unix_time(const char *time_str, const char *fmt, bool is_local)
{
	struct tm tm = {
		.tm_sec = 0,
		.tm_min = 0,
		.tm_hour = 0,
		.tm_mday = 1,
		.tm_mon = 0,
		.tm_year = 70,
		.tm_wday = 4,
		.tm_yday = 0,
		.tm_isdst = 0
	};
	char *endptr = strptime(time_str, fmt, &tm);
	if (endptr != NULL && *endptr != '\0') {
		fprintf(stderr, "failed to parse: %s (rest %s)\n",
			time_str, endptr);
		return 1;
	}
	time_t ts = mktime(&tm);
	if (ts == -1) {
		fprintf(stderr, "failed to convert to timestamp\n");
		return 1;
	}
	if (! is_local) {
		ts += tm.tm_gmtoff;
	}
	printf("%lld\n", ts);
	return 0;
}

/**
 * Print current unix time.
 */
static int get_unix_time()
{
	time_t ts = time(NULL);
	printf("%lld\n", ts);
	return 0;
}

/**
 * Format unix timestamp as a date with the provided format then print
 * to stdout.
 */
static int format_unix_time(const char *unix_time_str, const char *fmt,
			    bool is_local)
{
	time_t ts;
	if (! str_to_ll(unix_time_str, &ts)) {
		return 1;
	}

	struct tm tm;
	if (is_local) {
		if (localtime_r(&ts, &tm) == NULL) {
			fprintf(stderr, "failed to convert to local\n");
			return 1;
		}
	} else if (gmtime_r(&ts, &tm) == NULL) {
		fprintf(stderr, "failed to convert to UTC\n");
		return 1;
	}

	char buf[128] = {0};
	strftime(buf, sizeof(buf), fmt, &tm);
	printf("%s\n", buf);

	return 0;
}

/**
 * Print usage information.
 */
static int help(const char *name, int code)
{
	fprintf(stderr, "usage: %s command (args)\n", name);
	fprintf(stderr, "\n");
	fprintf(stderr, "  calc num [+-*/%] num\n");
	fprintf(stderr, "  format-unix-time timestamp format\n");
	fprintf(stderr, "  get-unix-time\n");
	fprintf(stderr, "  to-unix-time time format\n");
	fprintf(stderr, "\n");
	return code;
}

/**
 * Calc simple math operaetion in the form X + Y, X / Y etc.
 */
static int calc_op(const char *lhs_str, const char *op, const char *rhs_str)
{
	int64_t lhs, rhs;
	if (! str_to_ll(lhs_str, &lhs) || ! str_to_ll(rhs_str, &rhs)) {
		return 1;
	}

	int64_t res;
	if (strcmp(op, "+") == 0) {
		res = lhs + rhs;
	} else if (strcmp(op, "-") == 0) {
		res = lhs - rhs;
	} else if (strcmp(op, "*") == 0) {
		res = lhs * rhs;
	} else if (strcmp(op, "/") == 0) {
		if (rhs == 0) {
			fprintf(stderr, "division by zero\n");
			return 1;
		}
		res = lhs / rhs;
	} else if (strcmp(op, "%") == 0) {
		res = lhs % rhs;
	} else {
		fprintf(stderr, "unsupported operator %s\n", op);
		return 1;
	}

	printf("%lld\n", res);
	return 0;
}

static bool arg_is_local(int argc, char **argv, int max_arg)
{
	if (argc > (max_arg + 1)) {
		return strcmp(argv[max_arg + 1], "utc") == 0 ? false : true;
	}
	return false;
}

int main(int argc, char **argv)
{
	if (argc < 2) {
		return help(argv[0], 1);
	}

	const char *mode = argv[1];
	if (strcmp(mode, "format-unix-time") == 0 && argc > 3) {
		bool is_local = arg_is_local(argc, argv, 3);
		return format_unix_time(argv[2], argv[3], is_local);
	}
	if (strcmp(mode, "get-unix-time") == 0) {
		return get_unix_time();
	}
	if (strcmp(mode, "to-unix-time") == 0 && argc > 3) {
		bool is_local = arg_is_local(argc, argv, 3);
		return to_unix_time(argv[2], argv[3], is_local);
	}
	if (strcmp(mode, "calc") == 0 && argc == 5) {
		return calc_op(argv[2], argv[3], argv[4]);
	}

	return help(argv[0], 1);
}
