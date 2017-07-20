/*
 * Copyright Aurelian Melinte, 2008
 *
 * Virtual network demo. 
 * Released under GPL v3.0 or later.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <linux/types.h>
#include <linux/errqueue.h>
#include <errno.h>
#include <string.h>
#include <netdb.h>
#include <netinet/in.h>
#include <resolv.h>
#include <sys/time.h>
#include <sys/uio.h>
#include <arpa/inet.h>
#include <assert.h>

#include "ttools.h" 

static char *_progname = NULL; 


static void
usage(void)
{
    debug("Usage: %s remote-ip\n", _progname);
    debug("Example: %s  64.233.167.104\n", _progname);
}


int
main(int argc, char **argv)
{
    int pmtu = VPN_MAX_MTU; /*Bigger than Ethernet's*/
    
    if (argc != 2) {
        usage();
        exit(EXIT_FAILURE); 
    }
    _progname = argv[0]; 
    
    pmtu = path_mtu_to(argv[1], 32);
    debug("** Estimated path MTU to %s = %d\n", argv[1], pmtu); 

    return EXIT_SUCCESS; 
}
