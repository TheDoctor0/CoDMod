#!/usr/bin/env python3
"""Minimal GoldSrc rcon client for the test server.

Usage: python3 rcon.py status
"""

import socket
import sys

HOST = "127.0.0.1"
PORT = 27015
PASSWORD = "codmod"
HEADER = b"\xff\xff\xff\xff"


class Rcon:
    def __init__(self, host=HOST, port=PORT, password=PASSWORD, timeout=3.0):
        self.address = (host, port)
        self.password = password
        self.timeout = timeout

    def _send(self, payload):
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.settimeout(self.timeout)
        sock.connect(self.address)
        sock.send(payload)

        chunks = []

        try:
            while True:
                chunks.append(sock.recv(4096))
        except socket.timeout:
            pass
        finally:
            sock.close()

        # each packet is the 4 byte header plus a one byte type
        return "".join(c[5:].decode("utf-8", "replace") for c in chunks)

    def command(self, command):
        # reply is "challenge rcon <number>", empty while the server is starting
        reply = self._send(HEADER + b"challenge rcon\n").split()

        if len(reply) < 3:
            return ""

        return self._send(
            HEADER + f'rcon {reply[2]} "{self.password}" {command}\n'.encode()
        )


if __name__ == "__main__":
    print(Rcon().command(" ".join(sys.argv[1:])))
