"""Escribe texto en la consola de una VM de VirtualBox sin Guest Additions (teclado US), con keyboardputscancode.
Uso:  python vbtype.py "<vm>" "texto"   (agrega Enter al final; usar --sin-enter para no agregarlo)
"""
import subprocess
import sys
import time

VB = r"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
LET = dict(zip("abcdefghijklmnopqrstuvwxyz", "1e 30 2e 20 12 21 22 23 17 24 25 26 32 31 18 19 10 13 1f 14 16 2f 11 2d 15 2c".split()))
DIG = dict(zip("1234567890", "02 03 04 05 06 07 08 09 0a 0b".split()))
SIN = {" ": "39", "-": "0c", "=": "0d", "[": "1a", "]": "1b", ";": "27", "'": "28", "`": "29", "\\": "2b",
       ",": "33", ".": "34", "/": "35", "\t": "0f"}
CON = {"_": "0c", "+": "0d", "{": "1a", "}": "1b", ":": "27", '"': "28", "~": "29", "|": "2b", "<": "33", ">": "34", "?": "35",
       "!": "02", "@": "03", "#": "04", "$": "05", "%": "06", "^": "07", "&": "08", "*": "09", "(": "0a", ")": "0b"}


def codigos(ch):
    if ch in LET:
        return [LET[ch]]
    if ch in DIG:
        return [DIG[ch]]
    if ch in SIN:
        return [SIN[ch]]
    if ch.lower() in LET and ch.isupper():
        return ["2a", LET[ch.lower()]]
    if ch in CON:
        return ["2a", CON[ch]]
    raise ValueError(f"caracter no soportado: {ch!r}")


def pulsar(vm, ch):
    cs = codigos(ch)
    down = cs
    up = [format(int(c, 16) | 0x80, "02x") for c in reversed(cs)]
    subprocess.run([VB, "controlvm", vm, "keyboardputscancode", *down, *up], capture_output=True)


def escribir(vm, texto, enter=True, pausa=0.03):
    for ch in texto:
        pulsar(vm, ch)
        time.sleep(pausa)
    if enter:
        subprocess.run([VB, "controlvm", vm, "keyboardputscancode", "1c", "9c"], capture_output=True)


if __name__ == "__main__":
    vm, texto = sys.argv[1], sys.argv[2]
    escribir(vm, texto, enter="--sin-enter" not in sys.argv)
