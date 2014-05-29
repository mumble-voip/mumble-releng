#include <stdint.h>
#include <stdio.h>
#include <stdarg.h>
#include <math.h>

#include "common.h"

static int nfail = 0;
static int nok = 0;

static void t(const char *expected, const char *format, ...) {
	int ret;
	va_list	argptr;
	char buf[4096];

	va_start(argptr, format);
	ret = psf_vsnprintf(buf, sizeof(buf) * sizeof(*buf), format, argptr);
	va_end(argptr);

	if (ret == -1) {
		++nfail;
		fprintf(stderr, "%s failed: returned -1\n", format);
		return;
	}

	if (strcmp(expected, buf)) {
		++nfail;
		fprintf(stderr, "%s failed: got `%s`, want `%s`.\n", format, buf, expected);
		return;
	}

	++nok;
}

#ifdef _MSC_VER
static void invalid_parameter_handler(const wchar_t *expression, const wchar_t *function, 
                                      const wchar_t *file,  unsigned int line,
                                      uintptr_t pReserved) {
	// Do nothing.
}
#endif

int main(int argc, char *argv[]) {
	(void) argc;
	(void) argv;

#ifdef _MSC_VER
	_set_invalid_parameter_handler(invalid_parameter_handler);
#endif

	// format specifiers
	t("-1234", "%d", -1234);
	t("-1234", "%i", -1234);
	t("1234", "%u", 1234);
	t("750", "%o", 0750);
	t("cafe", "%x", 0xcafe);
	t("CAFE", "%X", 0xcafe);
	t("12.000000", "%f", 12.0f);
	t("12.000000", "%F", 12.0f);
	t("1.000000e+000", "%e", 1.0f);
	t("1.000000E+000", "%E", 1.0f);
	t("1", "%g", 1.0f);
	t("1", "%G", 1.0f);
	t("0x1.000000p+0", "%a", 1.0f);
	t("0X1.000000P+0", "%A", 1.0f);
	t("a", "%c", 'a');
	t("hello", "%s", "hello");
	t("00000000", "%p", NULL);
	// %n not tested
	t("%", "%%");

	t("1     hi", "%-5i %s", 1, "hi");
	t("+1", "%+i", 1);
	t(" 1", "% i", 1);
	t("0xcafe", "%#x", 0xcafe);
	t("1.000000", "%#f", 1.0f);
	t("00001", "%05i", 1);

	t("    1", "%5i", 1);
	t("    1", "%*i", 5, 1);

	t("", "%.0i", 0);
	t("00001", "%.5i", 1);
	t("00001", "%.*i", 5, 1);
	t("12.00", "%.2f", 12.0f);
	t("12.00", "%.*f", 2, 12.0f);

	signed char sc = -64;
	t("-64", "%hhi", sc);

	signed short ss = -512;
	t("-512", "%hi", ss);

	long l = 2147483647L;
	t("2147483647", "%li", l);

	long long ll = 9223372036854775807LL;
	t("9223372036854775807", "%lli", ll);

	intmax_t im = 18446744073709551615LL;
	t("18446744073709551615", "%ji", im);

	size_t s = 12345;
	t("12345", "%zi", s);

	ptrdiff_t pd = 0xcafebabe - 4;
	t("0xcafebaba", "%ti", pd);

	long double ld = 1.0l;
	t("1.000000", "%Lf", ld);

	fprintf(stderr, "\n%i ok\n%i failed\n", nok, nfail);

	return nfail != 0;
}