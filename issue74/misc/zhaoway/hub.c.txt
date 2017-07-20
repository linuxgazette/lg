/* -*- C -*-
 * lullaby internetworks lab: (server alike) hub
 *
 * Copyright (C) 2001  zhaoway <zw@debian.org>
 *
 * $Id: hub.c.txt,v 1.1.1.1 2002/08/14 22:28:21 dan Exp $
 *
 * Compile with: gcc -Wall -g -o hub hub.c
 */

#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <netinet/in.h>

void banner(void)
{
  printf("lullaby internetworks lab: (server alike) hub $Revision: 1.1.1.1 $\n"
	 "Copyright(C) 2001  zhaoway <zw@debian.org>\n\n");
}

void usage(void)
{
  banner();
  printf("Usage: hub [hub buffer size] [tcp port number] [number of hub ports]\n\n"
	 "o hub buffer size is in bytes. for example 10240.\n"
	 "o tcp port number is at least 1024 so i do not need to be root.\n"
	 "o number of hub ports is at least 2. happy.\n");
}

/* Return value -1 means failure. */
int make_socket(short int port)
{
  int listenfd, val;
  struct sockaddr_in servaddr;

  listenfd = socket(AF_INET, SOCK_STREAM, 0);
  memset(&servaddr, 0, sizeof(servaddr));
  servaddr.sin_family = AF_INET;
  servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
  servaddr.sin_port = htons(port);
  if ((bind(listenfd, (struct sockaddr *) &servaddr, sizeof(servaddr))) == -1)
    {
      perror("bind err");
      return -1;
    }
  listen(listenfd, 1);
  /* Set socket nonblocking. */
  val = fcntl(listenfd, F_GETFL);
  fcntl(listenfd, F_SETFL, val | O_NONBLOCK);
  return listenfd;
}

int main(int argc, char *argv[])
{
  int listenfd, *connfd, maxline, size, port, ports, i, j;
  fd_set rset, rset_memo, wset, wset_memo;
  char *buff;
  struct timeval nowait = { 0, 0 };

  if (argc != 4
      || (maxline = strtol(argv[1], NULL, 10)) == 0
      || (port = strtol(argv[2], NULL, 10)) == 0
      || (ports = strtol(argv[3], NULL, 10)) < 2)
    {
      usage();
      return(0);
    }
  banner();
  buff = (char *) malloc(maxline * sizeof(char));
  if (buff == NULL)
    {
      fprintf(stderr, "not enough memory!\n");
      return 1;
    }
  if ((listenfd = make_socket(port)) == -1)
    {
      usage();
      return -1;
    }
  printf("Hub listening on TCP port %i\n", port);
  connfd = malloc(ports * sizeof(int));
  if (connfd == NULL)
    {
      fprintf(stderr, "not enough memory!\n");
      return 1;
    }
  for (i = 0; i < ports; i++)
    {
      connfd[i] = -1;
    }
  FD_ZERO(&rset_memo);
  FD_ZERO(&wset_memo);
  /* Ignore this to receive EPIPE. */
  signal(SIGPIPE, SIG_IGN);
  /* Main loop. */
  for ( ; ; )
    {
      for (i = 0; i < ports; i++)
	{
	  if (connfd[i] == -1)
	    {
	      connfd[i] = accept(listenfd, NULL, NULL);
	      if (connfd[i] != -1)
		{
		  FD_SET(connfd[i], &rset_memo);
		  FD_SET(connfd[i], &wset_memo);
		}
	    }
	}
      /* Prepare for reading. */
      rset = rset_memo;
      /* If there is nothing available to be read? */
      if ((select(FD_SETSIZE, &rset, NULL, NULL, &nowait)) <= 0) continue;
      /* Search for the port which has something to be read. */
      for (i = 0; i < ports; i++)
	{
	  /* If this port is connected and there is something to be
	     read from it? */
	  if (connfd[i] == -1 || ! FD_ISSET(connfd[i], &rset)) continue;
	  /* If we have trouble reading? */
	  if ((size = recv(connfd[i], buff, maxline, 0)) == -1)
	    {
	      perror("recv err");
	      return errno;
	    }
	  /* If we actually read nothing? */
	  if (size == 0) continue;
	  /* Prepare for writing. */
	  wset = wset_memo;
	  /* If there is no port which is able to be written to? */
	  if ((select(FD_SETSIZE, NULL, &wset, NULL, &nowait)) <= 0) continue;
	  /* Loop searching for any port which is able to be written to. */
	  for (j = 0; j < ports; j++)
	    {
	      /* Do not write back to the sending port. */
	      if (j == i || connfd[j] == -1 || ! FD_ISSET(connfd[j], &wset))
		continue;
	      if ((send(connfd[j], buff, size, 0)) == -1)
		{
		  if (errno == EPIPE)
		    {
		      FD_CLR(connfd[j], &wset);
		      FD_CLR(connfd[j], &rset);
		      close(connfd[j]);
		      connfd[j] = -1;
		    }
		  else
		    {
		      perror("send err");
		      return errno;
		    }
		}
	    }
	}
    } /* Main loop. */
}
