/*
 * =====================================================================================
 *
 *       Filename:  tcpshoot.c
 *
 *    Description:  This is the sending side pendant to tcpsnoop.c. You can use it to
 *                  "shoot" a stream of data to a tcpsnoop server and measure the 
 *                  congestion window and its slow start threshold on the sending side.
 *
 *        Version:  1.0
 *        Created:  30/01/07 18:01:16 CET
 *       Revision:  none
 *       Compiler:  gcc-3.4
 *
 *         Author:  R. Pfeiffer (Mr), lynx@luchs.at
 *        Company:  http://web.luchs.at/
 *
 * =====================================================================================
 */

/*
 * Copyright (C) 2007 by René Pfeiffer <lynx@luchs.at>.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 * Please see the subversion logs for change details.
 *
 */

/*
 * Strategy:
 *
 * - open connection to target
 * - prepare statistics output (file or STDOUT)
 * - send payload
 * - periodically check tcp_info structure and print interesting values
 * - close and free everything
 *
 * Options:
 *
 * -b amount of bytes we copy from a file to the server before we print
 *    statistics
 * -c byte counter (bytes to send if you do not provide a file)
 * -d data to use (indicates a file)
 * -D debug mode
 * -f filename to write statistics to
 * -p server TCP port
 * -s server IP address
 */

/*
 * Get the header files we need
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <time.h>
#include <fcntl.h>
#include <errno.h>
#include <syslog.h>
#include <string.h>
#include <netdb.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include "tcpsnoop.h"

/*-----------------------------------------------------------------------------
 * Defaults
 *-----------------------------------------------------------------------------*/

const char default_filename[] = "tcpshoot.log";
const char default_server[]   = "localhost";

/*-----------------------------------------------------------------------------
 *  Main function
 *-----------------------------------------------------------------------------*/

int main( int argc, char **argv ) {
    /* Options with their defaults */
    unsigned short opt_buffer = DEFAULT_BUFFER;
    unsigned int opt_counter = DEFAULT_BYTES;
    char *opt_data = NULL;
    unsigned short opt_debug = 0;
    char *opt_filename = NULL;
    unsigned short opt_port = DEFAULT_PORT;
    char *opt_server = NULL;
    int option;
    /* File descriptors and data pointers */
    void *data = NULL;
    int datafd;
    void *position = NULL;
    FILE *statistics;
    /* Logic */
    static unsigned int bytecounter = 0;
    /* Structures needed for measuring time intervals */
    static struct timeval time_start, time_now, time_delta;
    /* TCP */
    static int tcp_socket;
    static struct sockaddr_in server_address;
    static struct hostent *server;
    static struct linger lingeropt;
    static struct tcp_info tcp_info;
    static int tcp_info_length;

    /* We won't run as root */
    if ( geteuid() == 0 ) {
        fprintf(stderr,"This program is not intended to run as superuser.\n");
        fprintf(stderr,"Please use a non-privileged user instead.\n");
        exit(EXIT_FAILURE);
    }

    /* Set default options */
    opt_filename = (char *)default_filename;
    opt_server   = (char *)default_server;

    /* Parse options */
    while ( (option = getopt(argc, argv, "b:c:d:D:f:hp:s:")) != -1 ) {
        switch ( option ) {
            case 'b':
                opt_buffer = (unsigned short)( strtoul( optarg, NULL, 10 ) );
                if ( opt_buffer < MIN_BUFFER ) {
                    opt_buffer = MIN_BUFFER;
                }
                break;
            case 'c':
                opt_counter = (unsigned int)( strtoul( optarg, NULL, 10 ) );
                if ( opt_counter < MIN_BYTES ) {
                    opt_counter = MIN_BYTES;
                }
                break;
            case 'd':
                opt_data = optarg;
                break;
            case 'D':
                opt_debug = (unsigned short)( strtoul( optarg, NULL, 10 ) );
                break;
            case 'f':
                opt_filename = optarg;
                break;
            case 'h':
                puts("Welcome! This is tcpshoot.\n" \
                     "Usage: tcpshoot [-b buffersize] [-c bytes] [-d datafile]\n" \
                     "       [-D debug] [-f logfile] [-h] [-p port] [-s server]\n");
                exit(EXIT_SUCCESS);
                break;
            case 'p':
                opt_port = (unsigned short)( strtoul( optarg, NULL, 10 ) );
                if ( opt_port < 1024 ) {
                    puts("We don't connect to privileged ports!\n");
                    exit(EXIT_FAILURE);
                }
                break;
            case 's':
                opt_server= optarg;
                break;
        }
    }

    /* If debug mode is enabled we print all options. */
    if ( opt_debug > 0 ) {
        fprintf(stdout,"Debug mode enabled. Will use TCP buffer of size %u.\n" \
                "Will connect to server %s on port %u.\n" \
                "Will write %u bytes.\n",
                opt_buffer, opt_server, opt_port, opt_counter
               );
    }

    /* Resolve server's name */
    server = gethostbyname( opt_server );
    if ( server == NULL ) {
        fprintf(stderr,"Could not resolve server name!\n");
        exit(EXIT_FAILURE);
    }

    /* Open the file we log the parameters to. */
    statistics = fopen( opt_filename, "a+" );
    if ( statistics == NULL ) {
        fprintf(stderr,"Could not open statistics file: %s\n",strerror(errno));
        exit(EXIT_FAILURE);
    }

    /* Create a TCP socket */
    tcp_socket = socket( PF_INET, SOCK_STREAM, IPPROTO_TCP );
    if ( tcp_socket == -1 ) {
        fprintf(stderr,"Could not open TCP socket: %s\n",strerror(errno));
        exit(EXIT_FAILURE);
    }
    else {
        /* Creation of the socket was successful. We now set the SO_LINGER option
         * so that our close() call waits until all packets are sent successfully.
         * We tell the socket to wait 13 seconds after our buffers have been sent.
         */
        lingeropt.l_onoff  = 1;
        lingeropt.l_linger = 13;
        if ( setsockopt( tcp_socket, SOL_SOCKET, SO_LINGER,
                         (void *)&lingeropt, sizeof(lingeropt) ) == -1 ) {
            fprintf(stderr,"Could not set SO_LINGER option: %s\n\\"
                           "Closing the socket will happen in the background.\n",strerror(errno));
        }
        /* Prepare a sockaddr structure with the server's address and port number
         * and connect.
         */
        server_address.sin_family = AF_INET;
        memcpy( &server_address.sin_addr.s_addr, server->h_addr, server->h_length );
        server_address.sin_port = htons(opt_port);
        if ( connect( tcp_socket, (struct sockaddr *)&server_address, sizeof(server_address) ) == -1 ) {
            fprintf(stderr,"Could not connect to server: %s\n",strerror(errno));
            exit(EXIT_FAILURE);
        }
    }

    /* Do we stream a file to a server? */
    if ( opt_data != NULL ) {
        /* Yes, we do. So let's open it. */
        datafd = open( opt_data, O_RDONLY );
        if ( datafd == -1 ) {
            fprintf(stderr,"Could not open file '%s'! (%s)\n", opt_data, strerror(errno) );
            exit(EXIT_FAILURE);
        }
        else {
            /* mmap file to memory for easier access. We don't need to copy buffers
             * around by taking advantage of this.
             */
            opt_counter = get_filesize(datafd);
            data = mmap( 0, opt_counter, PROT_READ, MAP_PRIVATE | MAP_NORESERVE, datafd, 0 );
            if ( data == MAP_FAILED ) {
                fprintf(stderr,"Can't map file '%s' to memory! (%s)\n", opt_data, strerror(errno) );
                close( datafd );
                close( tcp_socket );
            }
        }
    }
    else {
        /* Prepare memory buffer to be used with pseudorandom bytes and fill it with random data. */
        data = malloc( opt_buffer );
        if ( data == NULL ) {
            fprintf(stderr,"Can't allocate buffer of %u bytes length!\n", opt_buffer );
            close( tcp_socket );
            exit(EXIT_FAILURE);
        }
        else {
            memset( data, rand(), opt_buffer );
        }
    }

    /*-----------------------------------------------------------------------------
     * Our main loop where we send the data and write to the statistics file.
     *-----------------------------------------------------------------------------*/

    /* Mark start of transmission in log file. */
    if ( opt_data != NULL ) {
        fprintf(statistics,"; Writing file '%s' with size of %u bytes to server %s at port %u\n",
                opt_data, opt_counter, opt_server, opt_port );
    }
    else {
        fprintf(statistics,"; Writing %u random bytes to server %s at port %u\n",
                opt_counter, opt_server, opt_port );
    }
    /* position is our pointer to the current position in the data buffer. This is
     * only important when streaming a file since we have to move along the mmapped
     * memory region in steps of opt_counter bytes.
     */
    position = data;
    /* Stopwatch time. */
    get_now( &time_start, 1 );
    while ( bytecounter <= opt_counter ) {
        /* Send first portion of data */
        if ( send( tcp_socket, position, opt_buffer, 0 ) == -1 ) {
            fprintf(stderr,"Error '%s' while sending %u bytes.\n", strerror(errno), opt_buffer );
        }
        /* Refill the buffer or move the position pointer. */
        if ( opt_data != NULL ) {
            position += opt_buffer;
        }
        else {
            memset( data, rand(), opt_buffer );
        }
        bytecounter += opt_buffer;
        /* Measure time in order to create time intervals. */
        get_now( &time_now, 1 );
        /* Get struct tcp_info and extract parameters. */
        tcp_info_length = sizeof(tcp_info);
        if ( getsockopt( tcp_socket, SOL_TCP, TCP_INFO, (void *)&tcp_info, (socklen_t *)&tcp_info_length ) == 0 ) {
            /* Write parameters to file. */
            if ( opt_debug > 0 ) {
                fprintf(stdout,"Wrote line to log file after %u bytes sent.\n", bytecounter );
            }
            fprintf(statistics,"%.6f %u %u %u %u %u %u %u %u %u %u %u %u\n",
                    time_to_seconds( &time_start, &time_now ),
                    tcp_info.tcpi_last_data_sent,
                    tcp_info.tcpi_last_data_recv,
                    tcp_info.tcpi_snd_cwnd,
                    tcp_info.tcpi_snd_ssthresh,
                    tcp_info.tcpi_rcv_ssthresh,
                    tcp_info.tcpi_rtt,
                    tcp_info.tcpi_rttvar,
                    tcp_info.tcpi_unacked,
                    tcp_info.tcpi_sacked,
                    tcp_info.tcpi_lost,
                    tcp_info.tcpi_retrans,
                    tcp_info.tcpi_fackets
                   );
        }
    }

    /* We've done it. Free all resources. */
    close( tcp_socket );
    if ( opt_data == NULL ) {
        free( data );
    }
    else {
        if ( munmap( data, opt_counter ) == -1 ) {
            fprintf(stderr,"Error while unmapping the data file '%s'.\n", opt_data );
        }
        close( datafd );
    }
    fputs("; End of transmission\n", statistics);
    fclose( statistics );
    exit(EXIT_SUCCESS);
}

