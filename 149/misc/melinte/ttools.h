/*
 * Copyright Aurelian Melinte, 2008
 *
 * Virtual network demo. 
 * Released under GPL v3.0 or later.
 */
 
#ifndef _TTOOLS_H_
#define _TTOOLS_H_


#include <sys/socket.h>
#include <linux/types.h>
#include <linux/if_ether.h>
#include <sys/time.h>
#include <stdarg.h> 
#include <unistd.h>


/*Sometimes missing*/
#ifndef ETH_FCS_LEN
#  define ETH_FCS_LEN (4) 
#endif

#define ETH_MAX_PAYLOAD (ETH_DATA_LEN) /*Max MTU*/
#define ETH_OVERHEAD    (ETH_HLEN/*14*/ + ETH_FCS_LEN)

/*Actually of variable size. see also: linux/ip.h: struct iphdr*/
#define IP_HDR_SZ    (20) 
#define IP_OVERHEAD  IP_HDR_SZ

#define UDP_HDR_SZ   (8)
#define UDP_OVERHEAD UDP_HDR_SZ

#define VPN_UDP_PORT (11223)

#define VPN_OVERHEAD (ETH_OVERHEAD + IP_OVERHEAD + UDP_OVERHEAD)
#define VPN_PATH_MTU (ETH_MAX_PAYLOAD - VPN_OVERHEAD) 
#define VPN_MIN_MTU  (68)
#define INTERNET_MTU (576)

#define VPN_MAX_MTU      (2*ETH_MAX_PAYLOAD) 


/*Network byte order assumed.*/
typedef u_int32_t ip4_addr_t; 

int path_mtu_to(const char *ip4, unsigned int num_tries); 
int path_mtu_to_ip(ip4_addr_t ip4, unsigned int num_tries); 

/* Sample usage: mtu = get_if_mtu("eth0", sock); */
int get_if_mtu(const char *iface, int sock); 

int debug(const char *format, ...); 

/*
 * Calls restarted on EINTR
 */
int rselect(int n, fd_set *rds, fd_set *wds, fd_set *eds, 
            struct timeval *tout); 
ssize_t rread(int fd, void *buf, int len); 
ssize_t rwrite(int fd, const void *buf, int len); 
ssize_t rsend(int sock, const char *buf, int len, int flags); 
ssize_t rrecv(int sock, char *buf, int len, int flags); 
ssize_t rrecvfrom(int s, void *buf, size_t len, int flags, 
                  struct sockaddr *from, socklen_t *fromlen); 
ssize_t rsendto(int  s,  const void *buf, size_t len, int flags, 
                const struct sockaddr *to, socklen_t tolen); 
ssize_t rrecvmsg(int socket, struct msghdr *message, int flags); 


#endif /*_TTOOLS_H_*/
