
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdarg.h>

int puts(const char* format)
{
  size_t len = strlen(format);
  write(1, format, len);
  write(1, "\n", 1);
  return len;
}


int a_putchar(int c)
{
  char out = c & 0xff;
  return write(1, &out, 1);
  return c;
}


#define PAD_RIGHT 1
#define PAD_ZERO 2

static int prints(const char *string, int width, int pad)
{
	int pc = 0, padchar = ' ';

	if (width > 0) {
		int len = 0;
		const char *ptr;
		for (ptr = string; *ptr; ++ptr) ++len;
		if (len >= width) width = 0;
		else width -= len;
		if (pad & PAD_ZERO) padchar = '0';
	}
	if (!(pad & PAD_RIGHT)) {
		for ( ; width > 0; --width) {
			a_putchar (padchar);
			++pc;
		}
	}
	for ( ; *string ; ++string) {
		putchar (*string);
		++pc;
	}
	for ( ; width > 0; --width) {
		putchar (padchar);
		++pc;
	}

	return pc;
}

/* the following should be enough for 32 bit int */
#define PRINT_BUF_LEN 12

static int printi(int i, int b, int sg, int width, int pad, int letbase)
{
	char print_buf[PRINT_BUF_LEN];
	char *s;
	int t, neg = 0, pc = 0;
	unsigned int u = i;

	if (i == 0) {
		print_buf[0] = '0';
		print_buf[1] = '\0';
		return prints (print_buf, width, pad);
	}

	if (sg && b == 10 && i < 0) {
		neg = 1;
		u = -i;
	}

	s = print_buf + PRINT_BUF_LEN-1;
	*s = '\0';

	while (u) {
		t = u % b;
		if( t >= 10 )
			t += letbase - '0' - 10;
		*--s = t + '0';
		u /= b;
	}

	if (neg) {
		if( width && (pad & PAD_ZERO) ) {
			putchar ( '-');
			++pc;
			--width;
		}
		else {
			*--s = '-';
		}
	}

	return pc + prints (s, width, pad);
}

int print(int *varg)
{
	int width, pad;
	int pc = 0;
	char *format = (char *)(*varg++);
	char scr[2];

	for (; *format != 0; ++format) {
		
		if (*format == '%') {
			++format;
			width = pad = 0;
			if (*format == '\0') break;
			if (*format == '-') {
				++format;
				pad = PAD_RIGHT;
			}
			while (*format == '0') {
				++format;
				pad |= PAD_ZERO;
			}
			for ( ; *format >= '0' && *format <= '9'; ++format) {
				width *= 10;
				width += *format - '0';
			}
			if( *format == 's' ) {
				char *s = *((char **)varg++);
				pc += prints (s?s:"(null)", width, pad);
				continue;
			}
			if( *format == 'd' ) {
				pc += printi (*varg++, 10, 1, width, pad, 'a');
				continue;
			}
			if( *format == 'x' ) {
				pc += printi (*varg++, 16, 0, width, pad, 'a');
				continue;
			}
			if( *format == 'X' ) {
				pc += printi (*varg++, 16, 0, width, pad, 'A');
				continue;
			}
			if( *format == 'u' ) {
				pc += printi (*varg++, 10, 0, width, pad, 'a');
				continue;
			}
			if( *format == 'c' ) {
				// char are converted to int then pushed on the stack 
				scr[0] = *varg++;
				scr[1] = '\0';
				pc += prints (scr, width, pad);
				continue;
			}
		}
		else 
		{
			putchar(*format);
			++pc;
		}		
	}
	
	return pc;
}

/* assuming sizeof(void *) == sizeof(int) */

int printf(const char *format, ...)
{
	int *varg = (int *)(&format);
	return print(varg);
}


