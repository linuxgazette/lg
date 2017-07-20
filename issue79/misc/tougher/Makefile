# Makefile for XML stuff


all : simple_quoter_server simple_quoter_client

xmlrpc_objects = reply.o request.o server.o client.o \
	node.o socket.o server_socket.o client_socket.o

simple_quoter_server_objects = simple_quoter_server.o $(xmlrpc_objects)
simple_quoter_client_objects = simple_quoter_client.o $(xmlrpc_objects)


CXXFLAGS= -g -I/usr/local/include


simple_quoter_server: $(simple_quoter_server_objects)
	g++ -L/usr/local/lib -I/usr/local/include \
	-o sqs $(simple_quoter_server_objects) \
	-lexpat -lpthread

simple_quoter_client: $(simple_quoter_client_objects)
	g++ -L/usr/local/lib -I/usr/local/include \
	-o sqc $(simple_quoter_client_objects) \
	-lexpat -lpthread


simple_quoter_server.o : simple_quoter_server.cpp
simple_quoter_client.o : simple_quoter_client.cpp
reply.o : reply.cpp
request.o : request.cpp
node.o : node.cpp
socket.o : socket.cpp
server_socket.o : server_socket.cpp
client_socket.o : client_socket.cpp


clean :
	rm -f *.o sqs sqc
