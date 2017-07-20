#include <stdio.h>

char str[] = "I am a FreeBird ";

int main()
{
	int i = 0;
	while(1){
		write(1, &str[i++%16], 1);
		usleep(200);
	}
}	
