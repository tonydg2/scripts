import socket
import argparse

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Send UDP packets with a test payload.")
parser.add_argument("UDP_IP", help="The IP address of the target")
parser.add_argument("--port", type=int, default=12345, help="The UDP port to send the packet to (default: 12345)")
parser.add_argument("--payload", type=str, default="Test payload", help="The payload to send (default: 'Test payload')")
args = parser.parse_args()

# Set up the socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Send the payload
sock.sendto(args.payload.encode(), (args.UDP_IP, args.port))
print(f"Sent payload to {args.UDP_IP}:{args.port}")