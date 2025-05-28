import socket
import sys

if __name__ == "__main__":
    for group in sys.argv:
        for ip in group.split("\n"):
            try:
                print(socket.getnameinfo((ip, 0), 0)[0])
            except Exception as e:
                print(f"{ip} {e}")
