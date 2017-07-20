#include <stdio.h>
#include <stdlib.h>

/*

	This program is written to demonstrate the <stdlib.h> library.

	This program will demonstrate seaching and sorting and random numbers

	Written by James M. Rogers

	17 March 1999

	Released to the Public Domain on this date.

*/

#define ELEMENTS 50000

/* this is the compare program that we call with qsort to sort the array */
static int compar(const void *a, const void *b){
	return (strcmp( (char *)a, (char *)b));
}

main(){

	int x, i;
	char *string;
	struct sort_test_t {
		char s[16];
	} ;

	struct sort_test_t sort_test[ELEMENTS];

	/* initalize the pseudo-random sequence with the time */
	/* if you remove the following command then the program */
	/* will generate the same series of "random" numbers each */
	/* time the program is ran */
	srand(time());

	/* inititalize the array */
	for (i=0;i<ELEMENTS;i++) {
		/* produce a random variable */
		x=1+(100000.0*rand()/(RAND_MAX+1.0));
		/* load the variable into the string as an array */
		sprintf(sort_test[i].s,"%d\000", x);
	}

	/* sort the array */
	qsort(sort_test, ELEMENTS, sizeof(sort_test[0]), &compar);

	/* seach the array */

	if (string = bsearch("1000", sort_test, ELEMENTS, sizeof(sort_test[0]), &compar)) {
	    printf("The string 1000 is present.\n");
	} else {
	    printf("The string 1000 is not present!\n");
	}

	/* output the sorted array */
	for (i=0;i<ELEMENTS;i++) {
		printf("%d %s\n", i, sort_test[i].s);
	}

}
