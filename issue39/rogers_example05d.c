#include <stdio.h>
#include <stdlib.h>

/*

	This program is written to demonstrate the <stdlib.h> library.

	This program will demonstrate memory allocation using malloc.

	Written by James M. Rogers

	21 March 1999

	Released to the Public Domain on this date.

*/

struct element{
    struct element *next;
    int value;
}element_size;

struct element *initialize () {
    struct element *add;
    if(add=(struct element *)malloc(sizeof(element_size))){
        add->next = (struct element *)NULL;
        return add;
    } else {
	return (struct element *)NULL;
    }
}

struct element *push (struct element *top, int value) {

    struct element *add;

    if (add=(struct element *)malloc(sizeof(element_size))){

        add->next=top;
        add->value=value;
        top=add;
        return top;
    } else {
	printf("Failed to push a value onto the stack, I am quiting.\n");
	exit (1);
    }
}

struct element *pop (struct element *top, int *value) {

    struct element *remove;

    fflush(stdout);

    *value=top->value;
    remove=top;
    top=top->next;
    free(remove);
    
    return top;
}

main(){

    struct element *stack;
    int x;

    if ( !(stack = initialize())){
	printf("Failed to initialize the stack, I am quiting.\n");
	exit (1);
    }

    stack = push(stack, 1);
    stack = push(stack, 2);
    stack = push(stack, 4);
    stack = push(stack, 8);
    stack = push(stack, 16);
    stack = push(stack, 32);
    stack = push(stack, 64);
    stack = push(stack, 128);
    stack = push(stack, 256);

    while (stack = pop(stack, &x)){
        printf("Return value is \t%d\n", x);
    }
}
