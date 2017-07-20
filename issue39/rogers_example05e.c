#include <stdio.h>
#include <stdlib.h>

/*
	This program is written to demonstrate the <stdlib.h> library.
	This program will demonstrate memory allocation using calloc and realloc.
	Written by James M. Rogers
	21 March 1999
	Released to the Public Domain on this date.
*/

/*
	Read in lines from a file, reallocating memory as needed, then freeing when done.
*/

#define SIZE 1024

main(int argv, char *argc[]){

    char *file;
    char line[SIZE];
    FILE *stream;
    unsigned int mem_size, file_size, line_size;

    mem_size=SIZE;
    file_size=0;

    if((file=calloc(1,SIZE))==(char *)NULL){
	printf("Cannot allocate memory.\n");
	exit (1);
    }

    if((stream=fopen(argc[1], "r")) == (FILE *)NULL){
	printf("Cannot open file.");
	exit (1);
    }

    while(fgets(line, SIZE+1, stream) != (char *)NULL) { 
        printf("%s",line);
	line_size=strlen(line);
        file_size += line_size;
        while(file_size>mem_size) {
	    mem_size += SIZE;
	    if ((file=realloc(file, mem_size)) == (char *)NULL){
		printf("Cannot allocate memory.\n");
                free(file);
		fclose(stream);
		exit (1);
	    }
        }
        strcat(file,line);
	printf("allocated memory:%d \t file size:%d \t size of line:%d\n", mem_size, file_size, line_size);
	 
    }

    printf("%s",file);

    fclose(stream);
    free(file);
    exit (0);
}
