from bluetooth import *

port = 4
backlog = 1

server_sock=BluetoothSocket( RFCOMM )
server_sock.bind(("",port))
server_sock.listen(backlog)

client_sock, client_info = server_sock.accept()
print "Accepted connection from ", client_info

running=1
while running:
    data = client_sock.recv(10)
#    print "received:", data
    if data=='Hash': running=0
    if data=='Left': os.system("xevent -r -10 0")
    if data=='Right': os.system("xevent -r 10 0")
    if data=='Up': os.system("xevent -r 0 -10")
    if data=='Down': os.system("xevent -r 0 10")
    if data=='Select': os.system("xevent -b 1")     # button left
    if data=='Backspace': os.system("xevent 22 2")  # backspace
    if data=='1': os.system("xevent 36 2")    # Enter
    if data=='2': os.system("xevent -b 2")    # button middle
    if data=='3': os.system("xevent -b 3")    # button right
    if data=='4': os.system("xevent 99 2")    # PgUp
    if data=='5': os.system("xevent 98");     # Cursor up
    if data=='6': os.system("xevent 105 2")   # PgDown
    if data=='7': os.system("xevent 100 2")   # Cursor left
    if data=='8': os.system("xevent 104 2")   # Cursor down
    if data=='9': os.system("xevent 102 2")   # Cursor right
    if data=='Star': os.system("xevent 23 2") # Tab
    if data=='0': os.system("xevent 9 2")     # Escape

client_sock.close()
server_sock.close()
