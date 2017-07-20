#include <stdio.h>
#include <assert.h>

/*

	This program is written to demonstrate the <stdlib.h> library.

	This program will demonstrate the assert function

	Written by James M. Rogers

	12 April 1999

	Released to the Public Domain on this date.

*/

/*

    Compile this with the -DNDEBUG flag in order to _NOT_

    compile the assert statement.

    So all production boxes should compile with the -DNDEBUG flag.

*/

main (){

    int i=1;
    int j=0;
    assert(j!=0);
    printf("%s\n", i/j);
}
