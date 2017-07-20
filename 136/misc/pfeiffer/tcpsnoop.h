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
 * And please note that I haven't coded C since I used my Amiga. :)
 *
 */

#define DEFAULT_BUFFER      1500
#define DEFAULT_BYTES       16384
#define DEFAULT_DAEMON      1
#define DEFAULT_FILENAME    "tcpsnoop.log"
#define DEFAULT_LOOPS       100
#define DEFAULT_PORT        42237
#define DEFAULT_SLEEP       1

#define MAX_TCPOPT          256
#define MIN_BUFFER          576
#define MIN_BYTES           16384
#define FILENAME_MAXLENGTH  256
#define REPLY_MAXLENGTH     2048

#define SYSLOG_IDENTITY     "tcpsnoop"

/*-----------------------------------------------------------------------------
 *  Functions
 *-----------------------------------------------------------------------------*/

/* Get current time. */
void get_now( struct timeval *time, unsigned short debug ) {
    if ( gettimeofday( time, NULL ) != 0 ) {
        if ( debug > 0 ) {
            fprintf(stderr,"Can't get current time.\n");
        }
        else {
            syslog( LOG_DAEMON | LOG_INFO, "gettimeofday() failed. Can't get current time." );
        }
    }
    return;
}

/* Convert "struct timeval" to fractional seconds. */
double time_to_seconds ( struct timeval *tstart, struct timeval *tfinish ) {
    double t;

    t = (tfinish->tv_sec - tstart->tv_sec) + (tfinish->tv_usec - tstart->tv_usec) / 1e6;
    return t;
}

/* Get file size from file descriptor */
unsigned int get_filesize( int fd ) {
    struct stat s;

    if ( fstat( fd, &s ) == 0 ) {
        return(s.st_size);
    }
    else {
        return(0);
    }
}
