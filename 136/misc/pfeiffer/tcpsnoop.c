/*
 * tcpsnoop - this program listens on a port, accepts TCP transmissions
 * and writes statistics to a file or STDOUT.
 *
 * Copyright (C) 2006 by René Pfeiffer <lynx@luchs.at>.
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
 * And please note that I haven't coded C since I used my Amiga. :) This is
 * why we have not much functions and stuff everything into main(). Feel free to
 * clean it up (and send me patches).
 *
 * Useful links:
 * http://www.linuxhowtos.org/C_C++/socket.htm
 * ( http://www.linuxprofilm.com/articles/linux-daemon-howto.html )
 * http://wiki.java.net/bin/view/People/DaemonCreation
 * http://www.cprogramming.com/faq/cgi-bin/smartfaq.cgi?id=1044780608&answer=1108255660
 * http://www.enderunix.org/documents/eng/daemon.php
 * http://www.catb.org/~esr/cookbook/helloserver.c
 *
 */

/*
 * Strategy:
 *
 * - bind to a TCP port
 * - prepare statistics output (file or STDOUT)
 * - listen for incoming connections
 * - periodically check tcp_info structure and print interesting value
 *
 * Options:
 *
 * -b amount of bytes we copy from the network to a buffer (reporting, i.e.
 *    printing the parameters of the TCP connection is done after the buffer
 *    is full)
 * -p TCP port
 * -f filename
 * -d daemon mode or not
 * -D debug mode
 *
 */

/*
 * Get the header files we need
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
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
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include "tcpsnoop.h"

/*
 * Definitions
 */

const char default_filename[] = DEFAULT_FILENAME;

/*
 * Globals (we need those for closing/freeing resources from the signal handlers)
 */

/* File descriptor for log file */
FILE *statistics;

/* Things we need for dealing with TCP */
struct sockaddr_in server_address,client_address;
char *tcp_buffer;
struct tcp_info tcp_info;
int tcp_info_length;
int tcp_socket;
int tcp_work_socket;

/* Buffer for reply string */
int reply_size;
char reply_string[REPLY_MAXLENGTH];

/* Structures needed for measuring time intervals */
struct timeval time_start, time_now, time_delta;

/*
 * Functions
 */

/* Decode TCP options to string description. Please note that using strcat()
 * is highly dangerous and make sure you don't do it and never overwrite
 * your buffers! We use it here because we concatenate strings under our
 * control.
 */
void decode_tcp_options(char *options_text, u_int8_t tcp_options) {
    if ( (tcp_options & TCPI_OPT_TIMESTAMPS) ) {
        strcat(options_text, "Timestamps ");
    }
    if ( (tcp_options & TCPI_OPT_SACK) ) {
        strcat(options_text, "SACK ");
    }
    if ( (tcp_options & TCPI_OPT_WSCALE) ) {
        strcat(options_text, "Window Scaling ");
    }
    if ( (tcp_options & TCPI_OPT_ECN) ) {
        strcat(options_text, "ECN ");
    }
    return;
}

/* Handle SIGTERM and terminate daemon */
void signal_terminate( int signal ) {
    switch ( signal ) {
        case SIGTERM:
            syslog( LOG_DAEMON | LOG_INFO, "Received SIGTERM." );
            break;
        case SIGUSR1:
            syslog( LOG_DAEMON | LOG_INFO, "Received SIGUSR1." );
            break;
        default:
            syslog( LOG_DAEMON | LOG_INFO, "Received differen signal." );
    }

    /* Free TCP buffer, close log file and TCP socket. */
    free(tcp_buffer);
    fclose(statistics);
    close(tcp_socket);
    closelog();

    return;
}

/* Handle SIGHUP (just for debugging purposes and proof of 
 * "I have understood signal handlers"). Any code closing the current
 * log file and opening a new one could go into this function.
 */
void signal_hangup( int signal ) {
    if ( signal == SIGHUP ) {
        syslog( LOG_DAEMON | LOG_INFO, "Received SIGHUP." );
    }
    else {
        syslog( LOG_DAEMON | LOG_INFO, "Received SIGXFILES." );
    }
    return;
}

/* Signal handler configuration */
void set_signal_handlers( void ) {
    struct sigaction sighupSA, sigusr1SA, sigtermSA;

    /* We ignore these signals */
	signal(SIGUSR2,SIG_IGN);	
	signal(SIGPIPE,SIG_IGN);
	signal(SIGALRM,SIG_IGN);
	signal(SIGTSTP,SIG_IGN);
	signal(SIGTTIN,SIG_IGN);
	signal(SIGTTOU,SIG_IGN);
	signal(SIGURG,SIG_IGN);
	signal(SIGXCPU,SIG_IGN);
	signal(SIGXFSZ,SIG_IGN);
	signal(SIGVTALRM,SIG_IGN);
	signal(SIGPROF,SIG_IGN);
	signal(SIGIO,SIG_IGN);
	signal(SIGCHLD,SIG_IGN);

    /* We stop on these signals.
     */
	signal(SIGQUIT,signal_terminate);
	signal(SIGILL,signal_terminate);
	signal(SIGTRAP,signal_terminate);
	signal(SIGABRT,signal_terminate);
	signal(SIGIOT,signal_terminate);
	signal(SIGBUS,signal_terminate);
#ifdef SIGEMT /* this is not defined under Linux */
	signal(SIGEMT,signal_terminate);
#endif
	signal(SIGFPE,signal_terminate);
	signal(SIGSEGV,signal_terminate);
	signal(SIGSTKFLT,signal_terminate);
	signal(SIGCONT,signal_terminate);
	signal(SIGPWR,signal_terminate);
	signal(SIGSYS,signal_terminate);

    /* SIGTERM, SIGUSR1 - terminate immediately
     */
    sigtermSA.sa_handler = signal_terminate;
    sigtermSA.sa_flags   = 0;
    sigemptyset(&sigtermSA.sa_mask);
    sigaction( SIGTERM, &sigtermSA, NULL );

    sigusr1SA.sa_handler = signal_terminate;
    sigusr1SA.sa_flags   = 0;
    sigemptyset(&sigusr1SA.sa_mask);
    sigaction( SIGUSR1, &sigusr1SA, NULL );

/*     signal( SIGTERM, signal_terminate );
 *     signal( SIGUSR1, signal_terminate );
 */

    /* SIGHUP - we use this as a test signal and write a message
     * to syslog.
     */
    sighupSA.sa_handler = signal_hangup;
    sighupSA.sa_flags   = 0;
    sigemptyset(&sighupSA.sa_mask);
    sigaction( SIGHUP, &sighupSA, NULL );

/*     signal( SIGHUP, signal_hangup );
 */

    return;
}

/*
 * ---------------------------------------------------------------------------
 * The main part begins here
 */

int main( int argc, char **argv ) {
    /* Options with their defaults */
    unsigned short opt_buffer = DEFAULT_BUFFER;
    unsigned short opt_daemon = 0;
    unsigned short opt_debug = 0;
    char *opt_filename = NULL;
    unsigned short opt_port = DEFAULT_PORT;
    unsigned short opt_reply = 0;
    int option;
    /* Program logic */
    unsigned short debug_counter = DEFAULT_LOOPS;
    int client_length;
    int recv_bytes;
    int status;
    static char tcp_options_text[MAX_TCPOPT];
    /* Our process ID and Session ID */
    pid_t pid, sid;

    /* We won't run as root */
    if ( geteuid() == 0 ) {
        fprintf(stderr,"This program is not intended to run as superuser.\n");
        fprintf(stderr,"Please use a non-privileged user instead.\n");
        exit(EXIT_FAILURE);
    }

    /* Parse options */
    while ( (option = getopt(argc, argv, "b:dD:f:hrp:")) != -1 ) {
        switch ( option ) {
            case 'b':
                opt_buffer = (unsigned short)( strtoul( optarg, NULL, 10 ) );
                if ( opt_buffer < MIN_BUFFER ) {
                    opt_buffer = MIN_BUFFER;
                }
                break;
            case 'd':
                opt_daemon = 1;
                break;
            case 'D':
                opt_debug = (unsigned short)( strtoul( optarg, NULL, 10 ) );
                break;
            case 'f':
                opt_filename = optarg;
                break;
            case 'h':
                puts("Welcome to tcpsnoop!\\"
                     "Usage: tcpsnoop [-d] [-D debuglevel] [-f filename] [-h] [-p tcpport] [-b buffersize]");
                exit(EXIT_SUCCESS);
                break;
            case 'p':
                opt_port = (unsigned short)( strtoul( optarg, NULL, 10 ) );
                if ( opt_port < 1024 ) {
                    fprintf(stderr,"We can't bind to port %u! It is privileged.\n",opt_port);
                    exit(EXIT_FAILURE);
                }
                break;
            case 'r':
                opt_reply = 1;
                break;
        }
    }
    if ( opt_filename == NULL ) {
        opt_filename = (char *)default_filename;
    }
    /* Check for debug level. */
    if ( opt_debug > 0 ) {
        printf("Welcome to debug level %d!\n\\"
               "Will listen on port %u and write to file %s.\n\\"
               "Will allocate %u bytes for TCP buffer\n",
                opt_debug,opt_port,opt_filename,opt_buffer);
        /* We don't allow daemon mode when debug mode is active, no 
         * matter whether the daemon option is present or not.
         * */
        opt_daemon = 0;
    }
    if ( opt_daemon != 0 ) {
        syslog( LOG_DAEMON | LOG_INFO, "Starting daemon mode.");
    }

    /* Check if we should go into daemon mode */
    if ( opt_daemon != 0 ) {
        /* Fork and get a PID. */
        pid = fork();
        /* Check if forking was successful */
        if ( pid < 0 ) {
            fprintf(stderr,"fork() failed!\n");
            exit(EXIT_FAILURE);
        }
        if ( pid > 0 ) {
            syslog( LOG_DAEMON | LOG_INFO, "Got PID %u.", pid );
            exit(EXIT_SUCCESS);
        }
    }

    /* Set umask */
    umask(022);

    /* Here we open logs and files we probably need */
    /*
     *
     */
    openlog( SYSLOG_IDENTITY, LOG_PID, LOG_DAEMON );
    statistics = fopen( opt_filename, "a+" );
    if ( statistics == NULL ) {
        if ( opt_debug > 0 ) {
            fprintf(stderr,"Could not open statistics file: %s\n",strerror(errno));
        }
        else {
            syslog( LOG_DAEMON | LOG_CRIT, "Could not open statistics file: %s", strerror(errno) );
            exit(EXIT_FAILURE);
        }
    }

    /* Create a new SID for the child process */
    if ( opt_daemon != 0 ) {
        sid = setsid();
        if (sid < 0) {
            /* Could not aquire new SID. */
            syslog( LOG_DAEMON | LOG_CRIT, "%s", "Could not aquire new SID." );
            exit(EXIT_FAILURE);
        }
        /* Close standard file descriptors since daemons don't do standard
         * I/O. They need to use log files or syslog instead
         */
        fclose(stdout);
        fclose(stdin);
        fclose(stderr);
        set_signal_handlers();
    }

    /* Prepare TCP socket. */
    tcp_socket = socket( PF_INET, SOCK_STREAM, IPPROTO_TCP );
    if ( tcp_socket == -1 ) {
        /* Could not open socket. */
        if ( opt_debug > 0 ) {
            fprintf(stderr,"Could not open TCP socket: %s\n",strerror(errno));
        }
        else {
            syslog( LOG_DAEMON | LOG_CRIT, "Could not open TCP socket: %s", strerror(errno) );
        }
        exit(EXIT_FAILURE);
    }
    else {
        /* Bind to any address on local machine */
        server_address.sin_family = AF_INET;
        server_address.sin_addr.s_addr = INADDR_ANY;
        server_address.sin_port = htons(opt_port);
        memset((void *)&(server_address.sin_zero), '\0', 8);
        status = bind( tcp_socket, (struct sockaddr *)&server_address, sizeof(server_address) );
        if ( status == 0 ) {
            /* We can now listen for incoming connections. We only allow a backlog of one
             * connection
             */
            status = listen( tcp_socket, 1 );
            if ( status != 0 ) {
                /* Cannot listen on socket. */
                if ( opt_debug > 0 ) {
                    fprintf(stderr,"Cannot listen on socket: %s\n",strerror(errno));
                }
                else {
                    syslog( LOG_DAEMON | LOG_CRIT, "Cannot listen on socket: %s", strerror(errno) );
                }
                exit(EXIT_FAILURE);
            }
        }
        else {
            /* Cannot bind to socket. */
            if ( opt_debug > 0 ) {
                fprintf(stderr,"Cannot bind to socket: %s\n",strerror(errno));
            }
            else {
                syslog( LOG_DAEMON | LOG_CRIT, "Cannot bind to socket: %s", strerror(errno) );
            }
            exit(EXIT_FAILURE);
        }
    }
    
    /* Allocate Buffer for TCP stream data.
     * (We store it temporarily only since we act as an TCP sink.)
     */
    tcp_buffer = malloc(opt_buffer);
    if ( tcp_buffer == NULL ) {
        if ( opt_debug > 0 ) {
            fprintf(stderr,"Can't allocate buffer for TCP temporary memory.\n");
        }
        else {
            syslog( LOG_DAEMON | LOG_CRIT, "Can't allocate buffer for TCP temporary memory.\n" );
        }
        exit(EXIT_FAILURE);
    }

    /* Our main loop where we wait for (a) TCP connection(s). */
    if ( opt_debug > 0 ) {
        puts("Entering main loop.");
    }
    while ( debug_counter > 0 ) {
        client_length = sizeof(client_address);
        tcp_work_socket = accept( tcp_socket, (struct sockaddr *)&client_address, (socklen_t *)&client_length );
        /* Get time for counting milliseconds. */
        get_now( &time_start, opt_debug );
        /* As soon as we got a connection, we deal with the incoming data by using
         * a second socket. We only read as much as opt_buffer bytes.
         */
        if ( (recv_bytes = recv( tcp_work_socket, tcp_buffer, opt_buffer, 0 ) ) > 0 ) {
            /* Fill tcp_info structure with data to get the TCP options and the client's
             * name.
             */
            tcp_info_length = sizeof(tcp_info);
            if ( getsockopt( tcp_work_socket, SOL_IP, TCP_INFO, (void *)&tcp_info, (socklen_t *)&tcp_info_length ) == 0 ) {
                memset((void *)tcp_options_text, 0, MAX_TCPOPT);
                decode_tcp_options(tcp_options_text,tcp_info.tcpi_options);
                if ( opt_debug > 0 ) {
                    printf("Got a new connection from client %s.\n",inet_ntoa(client_address.sin_addr));
                }
                else {
                    syslog( LOG_DAEMON | LOG_INFO, "Received connection from client at address %s.",
                           inet_ntoa(client_address.sin_addr));
                }
                /* Write some statistics and start of connection to log file. */
                fprintf(statistics,"# Received connection from %s (AdvMSS %u, PMTU %u, options (%0.X): %s)\n",
                        inet_ntoa(client_address.sin_addr),
                        tcp_info.tcpi_advmss,
                        tcp_info.tcpi_pmtu,
                        tcp_info.tcpi_options,
                        tcp_options_text
                       );
            }
        }
        while ( (recv_bytes = recv( tcp_work_socket, tcp_buffer, opt_buffer, 0 ) ) > 0 ) {
            if ( opt_debug > 0 ) {
                printf("\nReceived %d bytes on socket.\n",recv_bytes);
            }
            /* Measure time in order to create time intervals. */
            get_now( &time_now, opt_debug );
            /* Fill tcp_info structure with data */
            tcp_info_length = sizeof(tcp_info);
            if ( getsockopt( tcp_work_socket, SOL_TCP, TCP_INFO, (void *)&tcp_info, (socklen_t *)&tcp_info_length ) == 0 ) {
                if ( opt_debug > 0 ) {
                    printf("snd_cwnd: %u\nsnd_ssthresh: %u\nrcv_ssthresh: %u\nrtt: %u\nrtt_var: %u\n",
                           tcp_info.tcpi_snd_cwnd,
                           tcp_info.tcpi_snd_ssthresh,
                           tcp_info.tcpi_rcv_ssthresh,
                           tcp_info.tcpi_rtt,
                           tcp_info.tcpi_rttvar
                          );
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
                if ( fflush(statistics) != 0 ) {
                    if ( opt_debug > 0 ) {
                        fprintf(stderr, "Cannot flush buffers: %s\n", strerror(errno) );
                    }
                    else {
                        syslog( LOG_DAEMON | LOG_CRIT, "Cannot flush buffers: %s", strerror(errno) );
                    }
                }
                /* Send reply text via TCP connection */
                if ( opt_reply != 0 ) {
                    reply_size = snprintf( reply_string, REPLY_MAXLENGTH, "rcv_ssthresh %u\n", tcp_info.tcpi_rcv_ssthresh );
                    if ( reply_size > 0 ) {
                        if ( send( tcp_work_socket, (void *)reply_string, reply_size, MSG_DONTWAIT ) == -1 ) {
                            if ( opt_debug > 0 ) {
                                fprintf(stderr, "Reply size %u didn't match: %s\n", reply_size, strerror(errno) );
                            }
                            else {
                                syslog( LOG_DAEMON | LOG_ERR, "Reply size %u didn't match: %s", reply_size, strerror(errno) );
                            }
                        }
                    }
                }
            }
        }
        close(tcp_work_socket);
        fprintf(statistics,"# Closed connection from %s.\n",inet_ntoa(client_address.sin_addr));
        if ( fflush(statistics) != 0 ) {
            if ( opt_debug > 0 ) {
                fprintf(stderr, "Cannot flush buffers: %s\n", strerror(errno) );
            }
            else {
                syslog( LOG_DAEMON | LOG_CRIT, "Cannot flush buffers: %s", strerror(errno) );
            }
        }
        if ( opt_debug > 0 ) {
            debug_counter--;
            printf("Closed connection. Decrementing debug counter to %u.\n\n",debug_counter);
        }
        else {
            syslog( LOG_DAEMON | LOG_INFO, "Closed connection from %s",
                   inet_ntoa(client_address.sin_addr));
        }
        sleep(DEFAULT_SLEEP);
    }

    /* That's a happy ending. */
    exit(EXIT_SUCCESS);
}
