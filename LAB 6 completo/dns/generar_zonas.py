"""Lab 6, DNS (puntos 2.1.g y 2.2.b): genera las zonas nuevas y los fragmentos de named.conf, sobre el BIND del Lab 3.

Dominios de la guia (grupo de 2): network.<student 01>.com.co y security.<student 02>.org.jp, ambos en el Apache de Solaris.
Cada dominio se configura en SU servidor DNS primario (Juan en Solaris, Camilo en Slackware, como en el Lab 3) y el otro
servidor lo copia como esclavo. Ademas se agregan nombres para los 3 servidores web del punto 2.1 en la zona camilo.org.uk.

Uso:  python generar_zonas.py [uni|casa]     uni = IP 10.2.78.x (red de la universidad), casa = 192.168.82.x (red interna lab-uni)
"""
import datetime
import os
import sys

MODOS = {
    "uni": {"slackware": "10.2.78.74", "solaris": "10.2.78.75", "windows": "10.2.78.76", "freebsd": "10.2.78.78"},
    "casa": {"slackware": "192.168.82.10", "solaris": "192.168.82.11", "windows": "192.168.82.13", "freebsd": "192.168.82.14"},
}
INTNET = {"slackware": "192.168.82.10", "solaris": "192.168.82.11"}  # para transferencias de zona (como en el Lab 3)
UNI_SOLARIS = "10.2.78.75"

# dominio -> (servidor primario, servidor esclavo, nombres A: nombre -> servidor al que apunta)
ZONAS = {
    "juan.com.co": ("solaris", "slackware", {"dns1": "solaris", "network": "solaris"}),
    "camilo.org.jp": ("slackware", "solaris", {"dns1": "slackware", "security": "solaris"}),
}
# nombres de los servidores web del punto 2.1, dentro de la zona del Lab 3 camilo.org.uk
WEB_21 = {"apache": "freebsd", "nginx": "slackware", "iis": "windows"}


def serial():
    return datetime.date.today().strftime("%Y%m%d") + "01"


def zona(dominio, hosts, ips):
    L = ["$TTL 86400", f"@ IN SOA dns1.{dominio}. root.{dominio}. (",
         f"    {serial()} ; serial (subirlo en cada cambio)", "    3600       ; refresh", "    900        ; retry",
         "    604800     ; expire", "    86400 )    ; negative cache TTL", "", f"@ IN NS dns1.{dominio}.", ""]
    for nombre, srv in hosts.items():
        L.append(f"{nombre}.{dominio}. IN A {ips[srv]}")
    return "\n".join(L) + "\n"


def main():
    modo = sys.argv[1] if len(sys.argv) > 1 else "uni"
    ips = MODOS[modo]
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "salida", modo)
    os.makedirs(out, exist_ok=True)
    conf = {"slackware": [], "solaris": []}
    for dom, (prim, sec, hosts) in ZONAS.items():
        open(os.path.join(out, f"{dom}.hosts"), "w", encoding="utf-8", newline="\n").write(zona(dom, hosts, ips))
        conf[prim].append(f'zone "{dom}" IN {{\n\ttype master;\n\tfile "{dom}.hosts";\n'
                          f'\tallow-transfer {{ {INTNET[sec]}; }};\n\tnotify yes;\n}};\n')
        masters = f"{ips[prim]};"   # solo la IP del modo: una IP inalcanzable como primera maestra retrasa la transferencia
        conf[sec].append(f'zone "{dom}" IN {{\n\ttype slave;\n\tmasters {{ {masters} }};\n\tfile "{dom}.slave";\n}};\n')
    for srv, bloques in conf.items():
        d = "/etc/DNS" if srv == "slackware" else "/etc/inet/DNS"
        cab = f"// Agregar al final de /etc/named.conf de {srv}. Archivos de zona en {d} (directory del options).\n\n"
        open(os.path.join(out, f"named.conf.{srv}.agregar"), "w", encoding="utf-8", newline="\n").write(cab + "\n".join(bloques))
    lineas = ["; Agregar al final de camilo.org.uk.hosts (Slackware, /etc/DNS) y SUBIR el serial de la zona.",
              "; Nombres de los 3 servidores web del punto 2.1 del Lab 6."]
    lineas += [f"{n}.camilo.org.uk. IN A {ips[s]}" for n, s in WEB_21.items()]
    open(os.path.join(out, "camilo.org.uk.hosts.agregar"), "w", encoding="utf-8", newline="\n").write("\n".join(lineas) + "\n")
    print(f"Modo {modo}: archivos en {out}")
    for f in sorted(os.listdir(out)):
        print("  ", f)


if __name__ == "__main__":
    main()
