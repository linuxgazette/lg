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
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/errqueue.h>
#include <linux/if.h>
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

#define OVERHEAD     (IP_HDR_SZ + UDP_HDR_SZ)


int 
rselect(int n, fd_set *rds, fd_set *wds, fd_set *eds, struct timeval *tout)
{
    int rc;
    
    do {
        rc = select( n, rds, wds, eds, tout );
    } while ( rc == -1 && errno == EINTR );
    
    return rc;
}

ssize_t
rread(int fd, void *buf, int len)
{
    ssize_t ret;
    
    do {
        ret = read( fd, buf, len );
    } while ( ret == -1 && errno == EINTR );
    return ret;
}

ssize_t  
rwrite(int fd, const void *buf, int len)
{
    ssize_t ret;
    
    do {
        ret = write( fd, buf, len );
    } while ( ret == -1 && errno == EINTR );
    return ret;
}

ssize_t 
rsend(int sock, const char *buf, int len, int flags)
{
    ssize_t ret;
    
    do {
        ret = send( sock, buf, len, flags );
    } while ( ret == -1 && errno == EINTR );
    return ret;
}

ssize_t  
rrecv( int sock, char *buf, int len, int flags )
{
    ssize_t ret;
    
    do {
        ret = recv( sock, buf, len, flags );
    } while ( ret == -1 && errno == EINTR );
    return ret;
}

ssize_t 
rrecvfrom(int s, void *buf, size_t len, int flags, 
          struct sockaddr *from, socklen_t *fromlen)
{
    ssize_t rc;
    
    do {
        rc = recvfrom(s, buf, len, flags, from, fromlen); 
    } while ( rc == -1 && errno == EINTR );
    
    return rc;
}

ssize_t 
rsendto(int  s,  const void *buf, size_t len, int flags, 
        const struct sockaddr *to, socklen_t tolen)
{
    ssize_t rc;
    
    do {
        rc = sendto(s, buf, len, flags, to, tolen); 
    } while ( rc == -1 && errno == EINTR );
    
    return rc;
}

ssize_t
rrecvmsg(int socket, struct msghdr *message, int flags)
{
    int ret;
    
    do {
        ret = recvmsg( socket, message, flags );
    } while ( ret == -1 && errno == EINTR );
    return ret;
}

int 
open_sock()
{
    int sock = -1;
    int on;

    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        perror("socket");
        return -1;
    }

    on = IP_PMTUDISC_DO;
    if (setsockopt(sock, SOL_IP, IP_MTU_DISCOVER, &on, sizeof(on))) {
        perror("IP_MTU_DISCOVER");
        close(sock);
        return -1;
    }
    
    on = 1;
    if (setsockopt(sock, SOL_IP, IP_RECVERR, &on, sizeof(on))) {
        perror("IP_RECVERR");
        close(sock);
        return -1;
    }
    
    if (setsockopt(sock, SOL_IP, IP_RECVTTL, &on, sizeof(on))) {
        perror("IP_RECVTTL");
        close(sock);
        return -1;
    }

    return sock; 
}

int
send_probe(int sock, char *buf, int len, struct sockaddr_in *target)
{
    int wrote = -1;

    wrote = rsendto(sock, buf, len, 0, 
                    (struct sockaddr*)target, 
                    sizeof(struct sockaddr_in));
    if (wrote == -1) 
        perror("rsendto");

    debug("send_probe %d => %d\n", len, wrote);
    return wrote; 
}

void 
data_wait(int fd)
{
    fd_set fds;
    struct timeval tv;

    FD_ZERO(&fds);
    FD_SET(fd, &fds);
    tv.tv_sec = 1;
    tv.tv_usec = 0;
    rselect(fd+1, &fds, NULL, NULL, &tv);
}


void
print_err_origin(struct sockaddr_in *origin)
{
    char buf[INET_ADDRSTRLEN+1] = {0};
    
    if (origin != NULL) {
        if (inet_ntop(AF_INET, &origin->sin_addr, buf, sizeof(buf)))
            debug("Err from: %s\n", buf);
    }
}


/*
 * Returns:
 * - negative: error
 * - 0: cannot tell MTU
 * - positive: the detected MTU
 */
int
analyze_results(int sock)
{
    char cbuf[512] = {0};
    char sndbuf[VPN_MAX_MTU] = {0};
    struct iovec  iov;
    struct msghdr msg;
    struct cmsghdr *cmsg = NULL;
    struct sock_extended_err *err = NULL;
    struct sockaddr_in addr;
    int res; 
    int mtu = 0;

    data_wait(sock);
    if (rrecv(sock, sndbuf, sizeof(sndbuf), MSG_DONTWAIT) > 0) {
        debug("  reply received\n");
        return 0;
    }

    msg.msg_name = (unsigned char*)&addr;
    msg.msg_namelen = sizeof(addr);
    msg.msg_iov = &iov;
    msg.msg_iovlen = 1;
    msg.msg_flags = 0;
    msg.msg_control = cbuf;
    msg.msg_controllen = sizeof(cbuf);
    res = rrecvmsg(sock, &msg, MSG_ERRQUEUE);
    if (res < 0) {
        if (errno != EAGAIN)
            perror("recvmsg");
        return 0; 
    }

    for (cmsg = CMSG_FIRSTHDR(&msg); cmsg; cmsg = CMSG_NXTHDR(&msg, cmsg)) {
        if (cmsg->cmsg_level == SOL_IP) {
            if (cmsg->cmsg_type == IP_RECVERR) {
                err = (struct sock_extended_err *)CMSG_DATA(cmsg);
            } else if (cmsg->cmsg_type == IP_TTL) {
                debug("  IP_TTL rethops = %d\n", *(int*)CMSG_DATA(cmsg));
            } else { 
                debug("  cmsg:%d\n ", cmsg->cmsg_type); 
            }
        }
    }
    if (err == NULL) {
        debug("  analyze_results: No info\n");
        return 0;
    }


    print_err_origin((struct sockaddr_in *)SO_EE_OFFENDER(err));
    mtu = 0; 
    switch (err->ee_errno) {
    case ETIMEDOUT:
        debug("  Timedout\n");
        break;
    case EMSGSIZE:
        debug("  EMSGSIZE pmtu %d\n", err->ee_info);
        mtu = err->ee_info;
        break;
    case ECONNREFUSED:
        debug("  Connection refused\n");
        mtu = -1;
        break;
    case EPROTO:
        debug("  EPROTO\n");
        mtu = -1; 
        break;
    case EHOSTUNREACH:
        if (  err->ee_origin == SO_EE_ORIGIN_ICMP 
           && err->ee_type == 11 
           && err->ee_code == 0) {
            debug("  ?\n");
            break;
        }
        debug("  Host unreacheable\n");
        mtu = -1; 
        break; 
    case ENETUNREACH:
        debug("  Network unreacheable\n");
        mtu = -1; 
        break; 
    case EACCES:
        debug("  No access\n");
        mtu = -1;
        break; 
    default:
        debug("  err->ee_errno=%d\n", err->ee_errno);
        errno = err->ee_errno;
        mtu = -1;
        perror("NET ERROR");
        break;
    }

    return mtu; 
}


int 
path_mtu_to_ip(ip4_addr_t remote_ip, 
               unsigned int num_tries)
{
    struct sockaddr_in target;
    unsigned short port = 7; /*echo*/
    int sock = -1;
    int wrote = -1; 
    int mtu = VPN_MAX_MTU; 
    char buf[VPN_MAX_MTU] = {0}; 
    int new_mtu = 0; 
    
    if ((sock = open_sock()) < 0) {
        return -1; 
    }

    target.sin_addr.s_addr = remote_ip;
    target.sin_family = AF_INET;
    target.sin_port = htons(port);

    while (--num_tries > 0 && new_mtu >=0) {
        debug("[%d] Trying MTU %d\n", num_tries, mtu);
        wrote = send_probe(sock, buf, mtu, &target);
        
        new_mtu = analyze_results(sock);
        if (new_mtu - OVERHEAD > VPN_MIN_MTU) {
            mtu = new_mtu - OVERHEAD; 
        } else if (new_mtu != 0) {
            mtu = new_mtu; 
        }
    }
    
    if (mtu > 0 && mtu < VPN_MIN_MTU)
        mtu = VPN_MIN_MTU; 
        
    debug("PMTU is %d\n", mtu);
    return mtu; 
}

int 
path_mtu_to(const char *ip4, unsigned int num_tries)
{
    ip4_addr_t remote_ip = 0L; 
    
    if (0 >= inet_pton(AF_INET, ip4, &remote_ip)) {
        debug("Invalid IP address %s\n", ip4); 
        return -1;
    }
    
    return path_mtu_to_ip(remote_ip, num_tries); 
}


/* Get the MTU of the real interface */
int 
get_if_mtu(const char *iface, int sock)
{
    int mtu = VPN_PATH_MTU; 
    struct ifreq ifr_if;
    
    memset(&ifr_if, 0, sizeof(ifr_if));
    strncpy(ifr_if.ifr_name, iface, IFNAMSIZ - 1);
    if (ioctl(sock, SIOCGIFMTU, &ifr_if) < 0) {
        debug("SIOCGIFMTU: %s\n", strerror(errno));
        return -1;
    }

    if (ifr_if.ifr_mtu < VPN_MIN_MTU) {
        debug("Warning: MTU smaller than %d, cannot reduce MTU.\n", VPN_MIN_MTU);
        mtu = ifr_if.ifr_mtu; 
    } else 
        mtu = ifr_if.ifr_mtu - ETH_OVERHEAD - IP_OVERHEAD; 

    debug("%s: MTU is %d\n", iface, mtu);
    return mtu; 
}


int 
debug(const char *format, ...)
{
    va_list ap;
    int ret = -1;
    
    va_start(ap, format);
    ret = vprintf(format, ap);
    va_end(ap);
    
    return ret; 
}

