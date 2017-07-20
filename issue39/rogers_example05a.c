#include <stdio.h>
#include <stdlib.h>

/*

	This program is written to demonstrate the <stdlib.h> library.

	This program will demonstrate integer math

	Written by James M. Rogers

	17 March 1999

	Released to the Public Domain on this date.

*/

main(){

	int a, b;
	long int c, d;
	div_t x;
	ldiv_t y;

	a = 10;
	b = 3;

	x = div(a, b);
	printf(" div (%d, %d) returns a quotient of %d and a remainder of %d\n", a, b, x.quot, x.rem);

	c = 1000000;
	d = 337;

	y = ldiv(c, d);
	printf(" div (%d, %d) returns a quotient of %d and a remainder of %d\n", c, d, y.quot, y.rem);

	a = -100;

	b = abs(a);
	printf("The absolute value of %d is %d\n", a, b);

}
