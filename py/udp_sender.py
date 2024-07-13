import socket

# Replace <Ultra96_IP> with the actual IP address of your Ultra96
UDP_IP = "192.168.11.5"
UDP_PORT = 12345
PAYLOAD = "Test payload 666 adg"

# Set up the socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Send the message
sock.sendto(PAYLOAD.encode(), (UDP_IP, UDP_PORT))
print(f"Sent message to {UDP_IP}:{UDP_PORT}")