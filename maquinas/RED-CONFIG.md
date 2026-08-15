# Configuración de red — Laboratorio 01 (documentación técnica)

> IPs estáticas para la red de la universidad + NAT/DHCP para el hogar.
> Acceso remoto habilitado en las 4 VMs (SSH por llave) — sin necesidad de consola.

## Resumen de acceso remoto (desde el host)

| VM | Puerto | Usuario | Llave | Root |
|---|---|---|---|---|
| Slackware 15.0 | 2222 | vagrant | `.ssh/vagrant.key` | `sudo -n` (NOPASSWD) |
| Solaris 11.4 | 2223 | admin | `.ssh/gentle-ai` | `pfexec` (perfil All) |
| Windows Core | 2224 | Administrator | `.ssh/gentle-ai` | directo (admin) |
| Windows GUI | 2225 | Administrator | `.ssh/gentle-ai` | directo (admin) |

Ejemplo: `ssh -i .ssh/gentle-ai -p 2223 admin@127.0.0.1 "pfexec whoami"`

## IPs asignadas (estáticas para la universidad)

| VM | IP | Máscara | Gateway | DNS |
|---|---|---|---|---|
| Slackware | 10.2.78.64 | 255.255.0.0 | 10.2.65.1 | 10.2.65.1 |
| Solaris | 10.2.78.65 | 255.255.0.0 | 10.2.65.1 | 10.2.65.1 |
| Windows Core | 10.2.78.66 | 255.255.0.0 | 10.2.65.1 | 10.2.65.1 |
| Windows GUI | 10.2.78.67 | 255.255.0.0 | 10.2.65.1 | 10.2.65.1 |
| Android | DHCP | — | — | — |

> OJO: Windows Core y GUI todavía usan DHCP (NAT) — las estáticas .66/.67 se aplican en la uni (comandos en cada sección).

## Configuración por SO

### Slackware 15.0 (APLICADA)
- Archivo: `/etc/rc.d/rc.inet1.conf` (editado con **nano**)
  - `USE_DHCP[0]="no"`, `IPADDR[0]="10.2.78.64"`, `NETMASK[0]="255.255.0.0"`, `GATEWAY="10.2.65.1"`
- DNS: `/etc/resolv.conf` → `nameserver 10.2.65.1` (archivo directo, NO es symlink de resolvconf)
- Alias NAT (para SSH): `ip addr add 10.0.2.15/24 dev eth0` (persistente en `/etc/rc.d/rc.local`)
- Scripts guest: `/usr/local/bin/uni` (estática) y `/usr/local/bin/casa` (DHCP)

### Solaris 11.4 (APLICADA)
- `ipadm delete-addr net0/v4` (saca DHCP)
- `ipadm create-addr -T static -a local=10.2.78.65/16 net0/v4`
- `ipadm create-addr -T static -a local=10.0.2.15/24 net0/v4nat` (alias NAT para SSH)
- `route -p add default 10.2.65.1` (persistente)
- DNS: `/etc/resolv.conf` → `nameserver 10.2.65.1`
- Scripts guest: `/root/uni.sh` y `/root/casa.sh`
- SSH root: usuario `admin` con perfil `All` (`/etc/user_attr`) + entrada en `/etc/security/exec_attr.d/core-os`:
  `All:solaris:cmd:::*:uid=0;gid=0` (la original era RO y no elevaba)

### Windows Server Core (PENDIENTE estática — DHCP actual)
- En la uni: `sconfig` → opción 8 (Network settings) o:
  ```
  netsh interface ipv4 set address name="Ethernet" static 10.2.78.66 255.255.0.0 10.2.65.1
  netsh interface ipv4 set dns name="Ethernet" static 10.2.65.1
  ```
- SSH: OpenSSH Server instalado (`dism /Online /Add-Capability /CapabilityName:OpenSSH.Server~~~~0.0.1.0`), servicio automático, regla firewall `sshd22` (IMPORTANTE: la regla del instalador no alcanzó para tráfico NAT-forward — hubo que crear la regla explícita)

### Windows Server GUI (PENDIENTE estática — DHCP actual)
- En la uni (PowerShell admin):
  ```
  New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.2.78.67 -PrefixLength 16 -DefaultGateway 10.2.65.1
  Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.2.65.1
  ```
- SSH: OpenSSH Server instalado + regla firewall `sshd22` explícita

### Android-x86
- Sin SSH (no aplica). DHCP. En la uni se configura desde los ajustes si el lab lo pide.

## Scripts del host (NAT ↔ Bridge)

- `uni.cmd` — pasa las 5 VMs a bridge (Wi-Fi) para la uni
- `casa.cmd` — vuelve las 5 VMs a NAT para el hogar
- En cada VM: correr el script `uni` (estática) o `casa` (DHCP) correspondiente

## Evidencia

- `lab-evidencias/red/` — pantallazos y salidas verificadas por VM
