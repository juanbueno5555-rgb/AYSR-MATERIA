# Configuracion de red - Laboratorio 02 (documentacion tecnica)

> IPs estaticas para la red de la universidad (10.2.0.0/16, gateway+DNS 10.2.65.1, SIN DHCP) + NAT/DHCP para el hogar.
> Acceso remoto habilitado en las 4 VMs (SSH por llave + WinRM en Windows Core) - sin necesidad de consola.

## Resumen de acceso remoto (desde el host)

| VM | Puerto NAT | Usuario | Llave | Root |
|---|---|---|---|---|
| Slackware 15.0 (`slackware-15.0`) | 2222 | vagrant | `.ssh/vagrant.key` | `sudo -n` (NOPASSWD) |
| Solaris 11.4 (`solaris-11.4`) | 2223 | admin | `.ssh/gentle-ai` | `pfexec` (perfil All) |
| Windows Server GUI (`windows-server-gui`) | 2225 | Administrator | `.ssh/gentle-ai` | directo (admin) |
| Windows Server Core (`windows-server-core`) | 2224 | Administrator | `.ssh/gentle-ai` | directo (admin) + WinRM 5985 |

Ejemplo: `ssh -i .ssh/gentle-ai -p 2223 admin@127.0.0.1 "pfexec ipadm show-addr"`

> OJO Solaris: el crontab root existe; el reloj del guest puede quedar atrasado tras savestate.

## IPs asignadas (estaticas para la universidad) - VERIFICADAS 22/08 y 23/08

| VM | IP | Mascara | Gateway | DNS |
|---|---|---|---|---|
| Slackware | 10.2.78.74 | 255.255.0.0 | 10.2.65.1 | 10.2.65.1 |
| Solaris | 10.2.78.75 | 255.255.0.0 | 10.2.65.1 | 10.2.65.1 |
| Windows GUI | 10.2.78.76 | 255.255.0.0 | 10.2.65.1 | 10.2.65.1 |
| Windows Core | 10.2.78.77 | 255.255.0.0 | 10.2.65.1 | 10.2.65.1 |

En la uni el acceso es por puerto 22 directo sobre la IP estatica (ej: `ssh -i .ssh/vagrant.key vagrant@10.2.78.74` o `ssh -i .ssh/gentle-ai Administrator@10.2.78.77`).

## Watchdog de red (Lab 02, 22/08)

Sistema PERIODICO en cada guest (cada ~60s, automatico y sin interaccion) que reemplaza al
auto-red de una sola corrida al boot (el cual fallaba si el NIC se cambiaba en caliente).

Logica de decision (identica conceptualmente en los 3 SO):
1. Si el gateway por defecto es `10.2.65.1` Y `10.2.65.1` responde a ping (red uni ALCANZABLE):
   - asegurar IP estatica en nic1 (Slackware eth0 / Solaris net0/v4 / Windows "Ethernet");
   - borrar cualquier IP 10.2.* que haya quedado en nic2/intnet (Slackware eth1 / Solaris net1/v4 /
     Windows "Ethernet 2") - **bug historico de la IP uni en la interfaz interna**;
   - no toca nada si ya esta correcto (idempotente, sin reinicios de servicios).
2. Cualquier otro gateway (hogar/NAT 10.0.2.2 u otra): asegurar DHCP en nic1 (10.0.2.x);
   limpiar residuos 10.2.* en nic1 y nic2; deja intacta una config DHCP sana.

El ping al gateway es la correccion clave: con la estatica de la uni aplicada en casa, la ruta
default "via 10.2.65.1" existe pero NO es alcanzable; el ping distingue uni real de residuo.

Hot-switch en caliente (controlvm nic1 bridged/nat con la VM encendida): la VM no se cae y el
watchdog auto-cura la config en <= 2 min (probado en Solaris 22/08; red hogar = bridge sin cable).

### Por guest (instalado y verificado 22/08)

| VM | Script | Disparo periodico | Boot |
|---|---|---|---|---|
| Slackware | `/usr/local/bin/auto-red.sh` | crontab de root: `*/1 * * * * /usr/local/bin/auto-red.sh` | `/etc/rc.d/rc.local` (`( sleep 10; auto-red.sh ) &`) |
| Solaris | `/root/auto-red.sh` | crontab de root: `* * * * * /usr/bin/sh /root/auto-red.sh` | SMF `svc:/site/auto-red` (manifest `/var/svc/manifest/site/auto-red.xml`) |
| Windows GUI | `C:\auto-red.ps1` + `C:\auto-red-wrapper.cmd` | schtasks `auto-red`: cada minuto, `RL HIGHEST`, usuario SYSTEM | registro Run + schtasks ONSTART (boot) |
| Windows Core | `C:\auto-red.ps1` | schtasks `auto-red`: cada minuto, `RL HIGHEST`, usuario SYSTEM | registro Run + schtasks ONSTART (boot) |

OJO Solaris: el cron clasico NO soporta el paso `*/1` - usar `* * * * *` (verificado 22/08).
OJO cron tras savestate: si el cron no dispara (reloj del guest congelado), `svcadm restart svc:/system/cron:default`.

## Scripts del host (NAT <-> Bridge)

- `uni.cmd` - pasa las 4 VMs del Lab 02+Core a BRIDGE con el adaptador **"Realtek PCIe GbE Family Controller"**
  (cable Ethernet de la uni). No toca el Lab 01 (android-x86).
  Tras conectar el cable, esperar <= 2 min: los watchdogs aplican las IPs solos (ya NO hace falta
  entrar a cada VM).
- `casa.cmd` - vuelve las 4 VMs a NAT y re-crea los forwards SSH (2222/2223/2225/2224 + WinRM 5985) por si se perdieron.
  Los watchdogs restauran DHCP solos.

## Configuracion por SO (detalle, VERIFICADA 22/08)

### Slackware 15.0
- Uni: `/usr/local/bin/uni` (estatica 10.2.78.74: pars rc.inet1.conf `USE_DHCP[0]="no"`, `IPADDR[0]="10.2.78.74"`,
  `NETMASK[0]="255.255.0.0"`, `GATEWAY="10.2.65.1"`; flush eth0; rc.inet1 restart; resolv.conf 10.2.65.1).
- Casa: `/usr/local/bin/casa` (rc.inet1.conf a DHCP + restart; resolv.conf 10.0.2.3).
- Nota: `/etc/rc.d/rc.dhcpcd` no existe - el stop de dhcpcd de `uni` falla silencioso; el alias
  `ip addr add 10.0.2.15/24 dev eth0` en rc.local + watchdog limpian/restauran el resto.

### Solaris 11.4
- Uni: `/root/uni.sh` (`ipadm delete-addr net0/v4`; static `10.2.78.75/16`; alias NAT `10.0.2.15/24`
  como `net0/v4nat`; `route -p add default 10.2.65.1`; resolv.conf 10.2.65.1).
- Casa: `/root/casa.sh` (borra net0/v4 y v4nat; DHCP en net0/v4; `route -p delete default 10.2.65.1`; resolv.conf 10.0.2.3).
- BUG CORREGIDO 22/08: la IP uni habia quedado en `net1/v4` (intnet); el watchdog la elimina.
- SSH root: usuario `admin` con perfil `All` resiste (tambien root cron: `ipadm` lo permite).

### Windows Server GUI
- Watchdog `C:\auto-red.ps1`: gateway 10.2.65.1 alcanzable -> `netsh ... static 10.2.78.76 255.255.0.0 10.2.65.1`
  + DNS 10.2.65.1 en "Ethernet"; borra estatica 10.2.* de "Ethernet 2"; si no -> `source=dhcp`.
- El log del watchdog: `C:\Windows\Temp\auto-red.log`.
- SSH: OpenSSH Server instalado; regla firewall `sshd22` explicita (necesaria para NAT forward).
- El teclado del guest NO mapea `"` ni `=` al teclear desde el host (layout): los scripts se
  instalaron por SSH/base64; al teclear a mano en la consola usar `netsh interface ipv4 set address Ethernet dhcp`.

### Windows Server Core (AGREGADO AL ESQUEMA 23/08)
- Watchdog `C:\auto-red.ps1` (igual patron que GUI): gateway 10.2.65.1 alcanzable ->
  `netsh ... static 10.2.78.77 255.255.0.0 10.2.65.1` + DNS 10.2.65.1 en "Ethernet"; si no -> `source=dhcp`.
- Log: `C:\Windows\Temp\auto-red.log`. Tarea `auto-red` cada minuto (SYSTEM) + registro Run (boot).
- SSH: OpenSSH Server (reglas `OpenSSH SSH Server (sshd)` y `sshd22` activas) — forward NAT 2224 (casa).
- WinRM: `Enable-PSRemoting` habilitado; perfil de red en `Private`; forward NAT 5985 (casa).
- OJO: traia la IP vieja estatica 10.2.78.66/16 (Lab 01) en "Ethernet" — el watchdog la reemplaza
  por .77 en la uni y por DHCP en casa (bug corregido 23/08: sin esto, en casa quedaba muerto).

## Evidencia

- `lab-evidencias/red/` - salidas verificadas por VM.
- Logs watchdog: Slackware `/var/log/messages` (logger -t auto-red), Solaris `/var/adm/messages`,
  Windows `C:\Windows\Temp\auto-red.log` y `C:\Windows\Temp\auto-red-wrapper.log`.

## Snapshots y OVAs (22/08 y 23/08)

- Snapshot por VM (Lab 02): `estado-watchdog-2026-08-22` (descripcion: "Watchdog periodico + fix NIC nic1 aplicado. 22/8/2026").
- Snapshot Core (23/08): `estado-watchdog-2026-08-23` ("Watchdog periodico + IP uni 10.2.78.77 + WinRM + SSH. 23/8/2026").
- OVAs RE-EXPORTADAS 23/08 del estado watchdog (con watchdog + Core .77 en el esquema):
  `*-copia-1.ova` en `E:\maquinas-lab\OVA\` (slackware 3,85 GB, solaris 1,79 GB, core 8,67 GB, gui 14,71 GB).
  (si `E:` no existe: `C:\Users\RANGE\Downloads\maquinas\copias\`).