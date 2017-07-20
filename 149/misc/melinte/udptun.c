/*
 * Copyright Aurelian Melinte, 2008
 *
 * Virtual network demo. 
 * Released under GPL v3.0 or later.
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <errno.h>
#include <stdarg.h>
#include <signal.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <net/route.h>
#include <netinet/ip.h>
#include <netinet/if_ether.h>
#include <linux/if.h>
#include <linux/if_tun.h>
#include <linux/if_tunnel.h>
#include <fcntl.h>
#include <pthread.h> 
#include <sys/select.h>
#include <unistd.h>

#include "ttools.h" 

static int  _do_exit = 0;
static char *_progname = NULL; 
static int  _tun_fd = -1; 
static int  _udp_fd = -1; 
static ip4_addr_t _remote_ip = 0L; /*Network byte order*/



void 
close_tun_iface(void) 
{
    int close_ret = -1;
#if 0
    if (ioctl( fd, TUNSETPERSIST, 0 ) < 0) {
        /*debug("Error - cannot delete tun device: %s\n", strerror(errno));*/
        return;
    }
#endif
    if (_tun_fd != -1) {
        close_ret = close(_tun_fd);
        _tun_fd = -1;
        debug("Closing tun iface: [%d] %s.\n", close_ret, strerror(errno));
    }
}


/*ip4 is in network byte order*/
int 
set_ip(struct ifreq *ifr_tun, int sock, ip4_addr_t ip4)
{
    struct sockaddr_in addr;

    /* set the IP of this end point of tunnel */
    memset( &addr, 0, sizeof(addr) );
    addr.sin_addr.s_addr = ip4; /*network byte order*/
    addr.sin_family = AF_INET;
    memcpy( &ifr_tun->ifr_addr, &addr, sizeof(struct sockaddr) );

    if ( ioctl(sock, SIOCSIFADDR, ifr_tun) < 0) {
        debug("%s: socket SIOCSIFADDR: %s\n", _progname, strerror(errno));
        close(sock);
        return -1;
    }

    return 0; 
}

int 
set_mtu(struct ifreq *ifr_tun, int sock, unsigned int mtu)
{
    /* Set the MTU of the tap interface */
    ifr_tun->ifr_mtu = mtu; 
    if (ioctl(sock, SIOCSIFMTU, ifr_tun) < 0)  {
        debug("%s: SIOCSIFMTU: %s\n", _progname, strerror(errno));
        return -1;
    }

    debug("MTU was set to %d\n", mtu);
    return 0;
}

void
set_mac(int sock) /*socket(PF_INET, SOCK_DGRAM, 0);*/
{
    struct ifreq ifr;
    unsigned char mac[ETHER_ADDR_LEN+1] = {0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x0}; 
    int i;
    
    debug("Setting MAC.");

    memset(&ifr, 0, sizeof(struct ifreq));
    strncpy(ifr.ifr_name, "tap0", IFNAMSIZ);
    for (i=0; i<ETHER_ADDR_LEN; i++)
        ifr.ifr_hwaddr.sa_data[i] = mac[i];
    if (ioctl(sock, /*SIOCSPHYSADDR*/SIOCSIFHWADDR, &ifr) == -1) {
        debug("%s: Cannot set MAC adress for '%s' because '%s' (%d)\n", 
               _progname, "tun0", strerror(errno), errno);
    }
}


/* local_ip4 is in network byte address order.*/
int 
open_tun_iface(ip4_addr_t local_ip4) 
{
    struct ifreq ifr_tun; 
    int fd = -1; 
    int sock = -1; 
    int mtu = VPN_PATH_MTU; 
    
    if ((fd = open("/dev/net/tun", O_RDWR)) < 0) {
        debug("%s: Cannot open /dev/net/tun: %s. Do modprobe tun; lsmod\n", _progname, strerror(errno));
        return -1;
    }

    memset( &ifr_tun, 0, sizeof(ifr_tun) );
    ifr_tun.ifr_flags = IFF_TAP | IFF_NO_PI;
    if ((ioctl(fd, TUNSETIFF, (void *)&ifr_tun)) < 0) {
        debug("%s: TUNSETIFF error: %s\n", _progname, strerror(errno));
        close(fd);
        return -1;
    }

#if 0
    if (ioctl(fd, TUNSETPERSIST, 1) < 0) {
        debug("%s: TUNSETPERSIST error: %s\n", _progname, strerror(errno));
        close(fd);
        return -1;
    }
#endif

    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        debug("%s: Cannot open udp socket: %s\n", _progname, strerror(errno) );
        close(fd);
        return -1;
    }

    if (set_ip(&ifr_tun, sock, local_ip4) < 0) {
        close(fd);
        close(sock);
        return -1;
    }
    
    
    if (ioctl(sock, SIOCGIFFLAGS, &ifr_tun) < 0) {
        debug("%s: SIOCGIFFLAGS: %s\n", _progname, strerror(errno));
        close(fd);
        close(sock);
        return -1;
    }

    ifr_tun.ifr_flags |= IFF_UP;
    ifr_tun.ifr_flags |= IFF_RUNNING;

    if (ioctl(sock, SIOCSIFFLAGS, &ifr_tun) < 0)  {
        debug("%s: SIOCSIFFLAGS: %s\n", _progname, strerror(errno));
        close(fd);
        close(sock);
        return -1;
    }
    

    /*mtu = get_if_mtu("eth0", sock);*/
    mtu = path_mtu_to_ip(_remote_ip, 32); 
    if (mtu <= 0) {
        mtu = INTERNET_MTU; 
    }

    if (mtu + VPN_OVERHEAD > VPN_MIN_MTU)
        mtu -= VPN_OVERHEAD;

    if (0 != set_mtu(&ifr_tun, sock, mtu)) {
        close(fd);
        close(sock);
        return -1;
    }

    debug("** TUN opened: %s\n", ifr_tun.ifr_name);
    close(sock);

    return fd;
}

/*-----------------------------------------------------------------*/
int 
open_udp_socket(void)
{
    int sock = -1; 
    
    sock = socket(PF_INET, SOCK_DGRAM, 0); 
    if (sock > 0) {
        int ret = -1; 
        struct sockaddr_in myaddr;
        int optval = 1;
        
        setsockopt( sock, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval) );

        myaddr.sin_family = AF_INET;
        myaddr.sin_port = htons(VPN_UDP_PORT);
        myaddr.sin_addr.s_addr = INADDR_ANY;    /* automatically fill with my IP*/
        memset(&(myaddr.sin_zero), '\0', 8);    /* zero the rest of the struct*/
        
        ret = bind(sock, (struct sockaddr*)&myaddr, sizeof(myaddr));
        if (ret < 0) {
            debug("%s: bind() %s\n", _progname, strerror(errno)); 
            close(sock);
            sock = -1; 
        }
    } else {
        debug("%s: socket() %s\n", _progname, strerror(errno)); 
    }

    return sock;
}
    
void *
receiver(void *data)
{
    char buf[VPN_MAX_MTU] = {0}; 
    struct sockaddr_in cliaddr = {0}; 
    int recvlen = -1; 
    int writelen = -1; 
    socklen_t clilen = sizeof(cliaddr); 
    
    while (!_do_exit) {
        recvlen = rrecvfrom(_udp_fd, buf, sizeof(buf), 0, (struct sockaddr*)&cliaddr, &clilen);
        debug("SR:%04d\n", recvlen);
        if (recvlen > 0) {
            writelen = rwrite(_tun_fd, buf, recvlen); 
            debug("TW:%04d\n", writelen);
            if (writelen < 0) {
                debug("%s: rwrite() %s [%d]\n", _progname, strerror(errno), errno); 
                break; 
            }
        } else if (recvlen < 0) {
            debug("%s: rrecvfrom() %s\n", _progname, strerror(errno)); 
            break; 
        } else if (recvlen == 0) {
            break; 
        }
    }

    debug("** Receiver ending.\n");
    pthread_exit(NULL);
}

void *
transmitter(void *data)
{
    char buf[VPN_MAX_MTU] = {0}; 
    struct sockaddr_in cliaddr; 
    int recvlen = -1; 
    int writelen = -1; 
    socklen_t clilen = sizeof(cliaddr); 
#if 1
    struct timeval  timeout = {1,0};
    fd_set master_set; 

    FD_ZERO(&master_set);
    FD_SET(_tun_fd, &master_set);
#endif
    
    cliaddr.sin_addr.s_addr = _remote_ip;
    cliaddr.sin_family = AF_INET;
    cliaddr.sin_port = htons(VPN_UDP_PORT);

    while (!_do_exit) {
        /*
         * The read call will not return when _tun_fd is closed. Use
         * select to cope with. 
         */
#if 1
        fd_set working_set;
        int rc; 

        memcpy(&working_set, &master_set, sizeof(master_set));
        timeout.tv_sec = 1;
        rc = rselect(_tun_fd + 1, &working_set, NULL, NULL, &timeout);
        if (rc < 0) {
            debug("%s: select() %s [%d]\n", _progname, strerror(errno), errno); 
            break;
        }

        if (rc == 0) { /*t-out expired*/
            continue; 
        }
#endif
        recvlen = rread(_tun_fd, buf, sizeof(buf));
        debug("TR:%04d\n", recvlen);
        if (recvlen > 0) {
            writelen = rsendto(_udp_fd, buf, recvlen, 0, (struct sockaddr*)&cliaddr, clilen); 
            debug("SW:%04d\n", writelen);
            if (writelen < 0) {
                debug("%s: rsendto() %s [%d]\n", _progname, strerror(errno), errno); 
                break; 
            }
        } else if (recvlen < 0) {
            debug("%s: read() %s [%d]\n", _progname, strerror(errno), errno); 
            if (errno != EINTR && !_do_exit)
                break; 
        } else if (recvlen == 0) {
            break; 
        }
    }

    debug("** Transmitter ending.\n");
    pthread_exit(NULL);
}

/*-----------------------------------------------------------------*/

static void 
sigexit(int signo)
{
    _do_exit = 1;
}

static void 
set_signal(int signo, void (*handler)(int))
{
    struct sigaction sa;

    memset(&sa, 0, sizeof(sa));

    sa.sa_handler = (void (*)(int))handler;
#ifdef SA_INTERRUPT
    sa.sa_flags = SA_INTERRUPT;
#endif
    sigaction(signo, &sa, NULL);
}


static void
usage(void)
{
    debug("Usage: %s tun-ip remote-ip\n", _progname);
    debug("Example: %s  172.16.0.1  10.10.10.10\n", _progname);
}

int 
main (int argc, char **argv)
{
    const char *tun_ip = NULL;    /*virtual*/
    const char *remote_ip = NULL; /*physical*/
    ip4_addr_t local_ip4 = 0L; 
    int rc = -1; 
    pthread_t tid_recv, tid_trans; 
    void *thread_ret = NULL;
    
    _progname = argv[0]; 
    if (argc != 3) {
        usage();
        exit(EXIT_FAILURE); 
    }
    
    tun_ip = argv[1]; 
    remote_ip = argv[2]; 
    
    if (0 >= inet_pton(AF_INET, tun_ip, &local_ip4)) {
        debug("%s: invalid IP address %s\n", _progname, tun_ip); 
        exit(EXIT_FAILURE); 
    }
    if (0 >= inet_pton(AF_INET, remote_ip, &_remote_ip)) {
        debug("%s: invalid IP address %s\n", _progname, remote_ip); 
        exit(EXIT_FAILURE); 
    }


    set_signal(SIGINT,  sigexit);
    set_signal(SIGQUIT, sigexit);
    
    _tun_fd = open_tun_iface(local_ip4); 
    if (_tun_fd < 0 ) {
        exit(EXIT_FAILURE); 
    }
    
    _udp_fd = open_udp_socket();
    if (_udp_fd < 0 ) {
        exit(EXIT_FAILURE); 
    }
    
    rc = pthread_create(&tid_recv,  NULL, receiver,    NULL);
    rc = pthread_create(&tid_trans, NULL, transmitter, NULL);
    
    while (!_do_exit) 
        sleep(1); 
        
    debug("** Shutting down...\n");
    close_tun_iface();
    shutdown(_udp_fd, 2); _udp_fd = -1;
    pthread_join(tid_recv,  &thread_ret);
    pthread_join(tid_trans, &thread_ret);

    return EXIT_SUCCESS; 
}


