# listen for UDP packets and print data payload

import socket

# Set up the socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("0.0.0.0", 12345))  # Listen on all interfaces on port 12345

print("Listening for UDP packets on port 12345...")

while True:
    data, addr = sock.recvfrom(1024)  # Buffer size is 1024 bytes
    print(f"Received message from {addr}: {data.decode()}")

