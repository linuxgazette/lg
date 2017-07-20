#include <stdio.h>
#include <stdlib.h>

/*
	This program is written to demonstrate the <stdlib.h> library.
	This program will demonstrate environmental functions of the stdlib library.
	Written by James M. Rogers
	22 March 1999
	Released to the Public Domain on this date.
*/

#define OVERWRITE 1
#define NO_OVERWRITE 0

void shutdown_1 () {
    printf("\nShutting down!\n\n");
}

void shutdown_2 () {
    printf("\nReally Shutting down!\n\n");
}

void shutdown_3 () {
    printf("\nReally Really Shutting down!\n\n");
}

void shutdown_4 () {
    printf("\nReally Really Really Shutting down!\n\n");
}

main(){

    atexit(shutdown_4);

    printf("I am displaying the environmental variable TESTING : ");
    printf("%s\n", getenv("TESTING"));

    printf("The following setenv will only set TESTING if TESTING is unset : ");
    if ( setenv("TESTING", "no_overwite", NO_OVERWRITE) )  {
	abort();
    } else {
	printf("%s\n", getenv("TESTING"));
    }

    atexit(shutdown_3);

    printf("I am unsetting TESTING.\n");
    unsetenv("TESTING");

    printf("The following setenv will only set TESTING if TESTING is unset : ");
    if ( setenv("TESTING", "no_overwite", NO_OVERWRITE) )  {
        abort();
    } else {
        printf("%s\n", getenv("TESTING"));
    }

    atexit(shutdown_2);

    printf("The following setenv will always set TESTING : ");
    if ( setenv("TESTING", "overwrite", OVERWRITE) ) {
	abort();
    } else {
	printf("%s\n", getenv("TESTING"));
    }

    atexit(shutdown_1);

    exit (0);
}
