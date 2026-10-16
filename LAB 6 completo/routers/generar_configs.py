"""Lab 6, punto 1 (Router Simulation): genera los comandos IOS de Router0 y Router1 para cada integrante,
las IP de los PC, y verifica por simulacion que con las rutas estaticas todos los PC se ven entre si.

Topologia de la guia: PC0 y PC1 -- Router0 --(serial 20.0.0.0/8)-- Router1 -- PC2 y PC3.
Uso:  python generar_configs.py            (escribe en .\\salida y verifica)
"""
import ipaddress as ip
import os

CLAVE_E, CLAVE_C, CLAVE_T = "ClaveE", "ClaveC", "ClaveT"  # supuesto: la guia dice "Clave E / C / T"
MOTD = "For exclusive use by RECO students"
SERIAL_NET = "20.0.0.0/8"

# Redes por estudiante segun la guia (Red No. 1..4). Student 01 = Juan, Student 02 = Camilo (como en el Lab 3).
SETUPS = {
    "camilo": {"estudiante": "Student 02", "router0": "Camilo", "router1": "Aguirre",
               "redes": ["72.0.0.0/8", "73.0.0.0/8", "74.0.0.0/8", "75.0.0.0/8"]},
    "juan": {"estudiante": "Student 01", "router0": "Juan", "router1": "Rangel",
             "redes": ["132.18.0.0/16", "132.19.0.0/16", "132.20.0.0/16", "132.21.0.0/16"]},
}


def primera(red, n):
    """n-esima direccion usable de la red (1 = gateway, 2 = PC)."""
    return str(list(ip.ip_network(red).hosts())[n - 1]) if ip.ip_network(red).prefixlen >= 16 else str(ip.ip_network(red)[n])


def modelo(cfg):
    r = cfg["redes"]
    serial = ip.ip_network(SERIAL_NET)
    return {
        "Router0": {"hostname": cfg["router0"], "ifs": {
            "GigabitEthernet0/0": (f"{primera(r[0], 1)}", r[0], "Red No. 1 hacia PC0"),
            "GigabitEthernet0/1": (f"{primera(r[1], 1)}", r[1], "Red No. 2 hacia PC1"),
            "Serial0/0/0": (str(serial[1]), SERIAL_NET, "Enlace serial hacia Router1 (DCE)")}},
        "Router1": {"hostname": cfg["router1"], "ifs": {
            "GigabitEthernet0/0": (f"{primera(r[2], 1)}", r[2], "Red No. 3 hacia PC2"),
            "GigabitEthernet0/1": (f"{primera(r[3], 1)}", r[3], "Red No. 4 hacia PC3"),
            "Serial0/0/0": (str(serial[2]), SERIAL_NET, "Enlace serial hacia Router0 (DTE)")}},
        "PCs": {"PC0": (primera(r[0], 2), r[0], primera(r[0], 1)), "PC1": (primera(r[1], 2), r[1], primera(r[1], 1)),
                "PC2": (primera(r[2], 2), r[2], primera(r[2], 1)), "PC3": (primera(r[3], 2), r[3], primera(r[3], 1))},
        # rutas estaticas con interfaz de salida (la guia lo pide): cada router llega a las redes del otro por el serial
        "rutas": {"Router0": [r[2], r[3]], "Router1": [r[0], r[1]]},
    }


def mascara(red):
    return str(ip.ip_network(red).netmask)


def ios(m, router, con_rutas=True, dce=False):
    d = m[router]
    L = ["enable", "configure terminal", f"hostname {d['hostname']}", f"banner motd #{MOTD}#",
         "no ip domain-lookup", f"enable secret {CLAVE_E}",
         "line console 0", " logging synchronous", f" password {CLAVE_C}", " login", " exit",
         "line vty 0 15", " logging synchronous", f" password {CLAVE_T}", " login", " exit"]
    for nombre, (addr, red, desc) in d["ifs"].items():
        L += [f"interface {nombre}", f" description {desc}", f" ip address {addr} {mascara(red)}"]
        if nombre.startswith("Serial") and router == "Router0":
            L.append(" clock rate 64000")  # el extremo DCE del cable serial es el que marca el reloj
        L += [" no shutdown", " exit"]
    if con_rutas:
        for red in m["rutas"][router]:
            L.append(f"ip route {ip.ip_network(red).network_address} {mascara(red)} Serial0/0/0")
    L += ["end", "copy running-config startup-config", ""]
    return "\n".join(L)


def alcanza(m, origen, destino, con_rutas):
    """Simula el reenvio: devuelve la lista de saltos o None si falla (sin ARP ni ICMP real)."""
    pcs = m["PCs"]
    r_of = {"PC0": "Router0", "PC1": "Router0", "PC2": "Router1", "PC3": "Router1"}
    dst_ip = ip.ip_address(pcs[destino][0])
    if ip.ip_address(pcs[origen][0]) in ip.ip_network(pcs[destino][1]):
        return [origen, destino]  # misma LAN
    ruta, actual = [origen], r_of[origen]  # el PC envia a su gateway
    for _ in range(4):
        ruta.append(actual)
        d = m[actual]
        for nombre, (addr, red, desc) in d["ifs"].items():  # red conectada
            if dst_ip in ip.ip_network(red) and not nombre.startswith("Serial"):
                return ruta + [destino]
        if con_rutas and any(dst_ip in ip.ip_network(r) for r in m["rutas"][actual]):
            actual = "Router1" if actual == "Router0" else "Router0"
            continue
        return None
    return None


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    out = os.path.join(here, "salida")  # solo verificacion.txt; los comandos de cada integrante van a su carpeta
    os.makedirs(out, exist_ok=True)
    informe = []
    for clave, cfg in SETUPS.items():
        m = modelo(cfg)
        dest = os.path.join(here, "..", clave, "packet-tracer")
        os.makedirs(dest, exist_ok=True)
        for r in ("Router0", "Router1"):
            open(os.path.join(dest, f"{clave}-{r}-{m[r]['hostname']}.txt"), "w", encoding="utf-8").write(ios(m, r))
            open(os.path.join(dest, f"{clave}-{r}-sin-rutas.txt"), "w", encoding="utf-8").write(ios(m, r, con_rutas=False))
        pcs = ["Configuracion de los PC (Desktop > IP Configuration):"]
        for n, (addr, red, gw) in m["PCs"].items():
            pcs.append(f"  {n}: IP {addr}  Mascara {mascara(red)}  Gateway {gw}")
        open(os.path.join(dest, f"{clave}-PCs.txt"), "w", encoding="utf-8").write("\n".join(pcs) + "\n")
        informe.append(f"\n=== {clave} ({cfg['estudiante']}): Router0={cfg['router0']}, Router1={cfg['router1']} ===")
        informe += pcs
        pcs_ok = list(m["PCs"])
        for etapa, con in (("SIN rutas estaticas (solo redes conectadas)", False), ("CON rutas estaticas", True)):
            informe.append(f"  Alcance {etapa}:")
            ok = fail = 0
            for a in pcs_ok:
                for b in pcs_ok:
                    if a < b:
                        r = alcanza(m, a, b, con)
                        ok += bool(r); fail += not r
                        informe.append(f"    {a} -> {b}: {'OK via ' + ' > '.join(r) if r else 'NO LLEGA'}")
            informe.append(f"    resumen: {ok} alcanzables, {fail} no alcanzables")
            if con:
                assert fail == 0, f"{clave}: con rutas deberian verse todos los PC"
            else:
                assert fail > 0, f"{clave}: sin rutas deberian fallar los PC de la otra mitad"
        # sanidad de direcciones: ninguna red se repite
        redes = [ip.ip_network(x) for x in cfg["redes"]] + [ip.ip_network(SERIAL_NET)]
        assert len({str(x) for x in redes}) == len(redes) and not any(a.overlaps(b) for i, a in enumerate(redes) for b in redes[i + 1:])
    texto = "\n".join(informe) + "\n"
    open(os.path.join(out, "verificacion.txt"), "w", encoding="utf-8").write(texto)
    print(texto)
    print("OK: configuraciones generadas en", out)


if __name__ == "__main__":
    main()
