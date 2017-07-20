from libdesklets.controls import Control

from Intp import Intp

from socket import *
import struct
import sys
import time

class ntp(Control, Intp):

    def __init__(self):
        Control.__init__(self)
	pass
    def __get_time(self):
     	Server = ''
	EPOCH = 2208988800L
	Server = '0.fedora.pool.ntp.org'
	client = socket( AF_INET, SOCK_DGRAM )
	data = '\x1b' + 47 * '\0'
       	client.sendto( data, ( Server, 123 ))
       	data, address = client.recvfrom( 1024 )
       	if data:
        	t = struct.unpack( '!12I', data )[10]
           	t -= EPOCH
          	return time.ctime(t)
    ntp_time=  property(__get_time, doc = "the current time")     

def get_class():
	return ntp

