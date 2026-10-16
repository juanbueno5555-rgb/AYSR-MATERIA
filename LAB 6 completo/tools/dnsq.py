"""Consulta DNS (registro A) por UDP a 127.0.0.1:<puerto>. Uso: python dnsq.py nombre puerto"""
import random
import socket
import struct
import sys


def consulta_a(nombre, puerto, servidor="127.0.0.1"):
    qid = random.randrange(65536)
    q = struct.pack(">HHHHHH", qid, 0x0100, 1, 0, 0, 0) + b"".join(bytes([len(p)]) + p.encode() for p in nombre.split(".")) + b"\0" + struct.pack(">HH", 1, 1)
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(5)
    s.sendto(q, (servidor, puerto))
    r = s.recv(1024)
    rcode, an = r[3] & 15, struct.unpack(">H", r[6:8])[0]
    ips = []
    i = 12
    while r[i]:
        i += r[i] + 1
    i += 5
    for _ in range(an):
        i += 2 if r[i] & 0xC0 == 0xC0 else 0
        tipo, _, _, ln = struct.unpack(">HHIH", r[i:i + 10])
        if tipo == 1:
            ips.append(".".join(map(str, r[i + 10:i + 14])))
        i += 10 + ln
    return rcode, ips, bool(r[2] & 4)


if __name__ == "__main__":
    rc, ips, aa = consulta_a(sys.argv[1], int(sys.argv[2]))
    print(f"{sys.argv[1]} @127.0.0.1:{sys.argv[2]} -> rcode={rc} A={ips} autoritativa={aa}")
