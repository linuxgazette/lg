#include <stdio.h>
#include <stdlib.h>

/*

	This program is written to demonstrate the <stdlib.h> library.

	This program will demonstrate string to number conversions

	Written by James M. Rogers

	17 March 1999

	Released to the Public Domain on this date.

*/

main(){

	double a;
	int b;
	long int c;
	unsigned long int d;


	a = atof("1345");
	printf("%f\n", a);
	b = atoi("-345");
	printf("%d\n", b);
	c = atol("1234567890");
	printf("%d\n", c);
	a = strtod("9876543210.0123456789", (char **)NULL);
	printf("%f\n", a);
	c = strtol("157", (char **)NULL, 10);
	printf("%d\n", c);
	d = strtoul("47586", (char **)NULL, 10);
	printf("%d\n", d);

}
