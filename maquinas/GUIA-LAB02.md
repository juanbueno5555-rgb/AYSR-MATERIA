# Guía — Laboratorio No. 02: OS Setup, Shell y Software de Soporte de Red

> Grupo de 2 estudiantes: Camilo Aguirre y Juan David Rangel
> Curso: Arquitectura y Servicios de Red (AYSR) — Prof. John Alexander Pachón Pinzón
> Entrega: viernes 21 de agosto de 2026
> Las secciones "[grupos de tres]" NO aplican (somos 2).

---

## Mapa general

| Sección | Tema | Herramienta | Estado actual |
|---|---|---|---|
| 1 | Conocer Packet Tracer | Packet Tracer + curso Cisco | NUEVO |
| 2 | Rastreo de mensajes (PDUs) | Packet Tracer + Wireshark | NUEVO |
| 3 | Wireshark | Wireshark | NUEVO |
| 4 | Tarjetas de red | Host + VMs | Casi listo (datos de VMs del Lab 01) |
| 5 | Shell programming Unix | Slackware | NUEVO (scripts 1.1–1.4) |
| 6 | Editor VI | Slackware | NUEVO |
| 7 | Despliegue de VMs (2 por SO) | VirtualBox | Falta clonar |
| 8 | File sharing SMB/SAMBA | Solaris | NUEVO (lo más técnico) |

**VMs disponibles (del Lab 01):** slackware-15.0, solaris-11.4, windows-server-core,
windows-server-gui, android-x86 — todas funcionando, red estática 10.2.78.64-.68.
Credenciales en `CREDENCIALES.md`.

---

## 1. Getting to Know Packet Tracer

### 1.0 Antes de empezar — cuenta Cisco

1. Entrá a **NetAcad** (www.netacad.com) con tu cuenta.
2. Desde la plataforma, entrá al curso **"Getting Started with Cisco Packet Tracer"**.
3. Descargá **Packet Tracer** (la versión disponible en la plataforma — respondé esa versión en la pregunta 1 del lab).

### 1.1 Preguntas a responder (individual)

1. **¿Qué versión de Packet Tracer hay disponible en la plataforma Cisco?**
   → Mirá en NetAcad → Packet Tracer → descargas. Anotá versión exacta (ej. 8.2.x).
2. **Inscribirse al curso** "Getting Started with Cisco Packet Tracer" y **hacer un video resumen de los primeros 4 capítulos** (máx. 5 min). Participan los 2 integrantes.
3. **Quiz "Introduction to Packet Tracer - PT Basics Quiz"** — cada uno lo hace por su cuenta y saca **screenshot del resultado** (evidencia individual).

### 1.2 Armar el diagrama de red en Packet Tracer (individual)

Cada estudiante arma el diagrama de la consigna. La estructura típica (la del diagrama del lab):

```
            [PC-PT Cliente1]        [Server-PT DNS]
                  |                      |
        [Switch0]----------------[Switch1]
                  |                      |
            [Router0]============[Router2]     <- serial (rojo) entre R0 y R2
                  |                      |
            [Router1]---------------------  (según diagrama)
                  |        |        |
         [Server-PT DHCP] [Server-PT RADIUS] [Server-PT WEB/EMAIL]
```

**Dispositivos a colocar (según el diagrama de la consigna):**
- 3 routers: `Router0`, `Router1`, `Router2`
- Switches (L2 y/o L3) según el diagrama
- Servidores: `Server-PT RADIUS`, `Server-PT DHCP`, y los que muestre el diagrama (DNS, WEB, EMAIL, FILE...)
- PCs/clientes

**Conexiones:**
1. Conexiones **Ethernet** (negras): usar cable **Copper Straight-Through** (o Auto) entre PC↔Switch, Server↔Switch, Switch↔Router.
2. **Modificar la conexión Router0–Router2** para que use cable **Serial DCE/DTE** (rojo):
   - Borrar el cable actual entre R0 y R2 (clic derecho → Delete).
   - Ir a la pestaña de conexiones → elegir **Serial DCE**.
   - Conectar `Router0` (puerto Serial0/0/0) a `Router2` (Serial0/0/1 o el que toque).
   - Nota: el extremo DCE define el clock rate (se configura en la CLI: `clock rate 64000`), pero para el lab solo hay que **conectarlos** — la configuración de IPs viene después.

**Preguntas a responder (conceptuales):**
- **¿Qué representan las conexiones negras sólidas?**
  → Enlaces físicos Ethernet directos (cable cobre) entre dispositivos: la conexión de capa física real que transporta tramas (L1/L2). Sólido = hay cable físico conectado entre los puertos.
- **¿Qué representan las conexiones negras punteadas (dashed)?**
  → Conexiones **lógicas o virtuales**, no un cable físico directo: representan la relación lógica entre dispositivos (por ejemplo, una ruta a través de la red, un enlace inalámbrico, o un enlace que aún no está "activo" hasta configurarlo). En el diagrama, las punteadas suelen indicar dependencia lógica o conectividad que se completa con configuración.
  → *Nota: confirmar la interpretación con el material del curso y el diagrama exacto de la consigna.*

**Guardar:** el archivo `.pkt` de cada uno para subir (formato Packet Tracer).

---

## 2. Tracking Messages with Packet Tracer

### 2.1 Simulación: ping RADIUS → DHCP

Con el diagrama ya armado (y las IPs configuradas en los servers):

1. Clic en el toggle **Realtime → Simulation mode** (abajo a la derecha).
2. **Edit Filters** → marcar solo **ICMP**.
3. Doble clic en `Server-PT RADIUS` → pestaña **Desktop** → **Command Prompt**.
4. Escribir: `ping <IP de Server-PT DHCP>` (ej. `ping 192.168.1.2`) + Enter.
   → Aparecen 2 eventos en la lista: **ICMP echo request** y **ARP request** (el ARP resuelve la IP del destino a su MAC).
5. **Auto Capture / Play** → capturar los eventos. Clic OK en "No More Events".
6. **Examinar las PDUs capa por capa:**
   - Clic en cada paquete de la Event List → se abre la ventana **PDU Information** con las capas:
     - **Capa 2 (Ethernet)**: MAC origen/destino
     - **Capa 3 (IP)**: IP origen/destino
     - **Capa 4 (ICMP)**: tipo de mensaje
   - Observar que **cada capa agrega su encabezado** a los datos del usuario (encapsulación).

### 2.2 En la red real — Wireshark

Las mismas ideas (encapsulación capa por capa) se ven en tráfico real con Wireshark (sección 3).

---

## 3. Using Wireshark

### 3.1 Instalación y conceptos

1. **Instalar Wireshark** (www.wireshark.org/download.html) — en casa y/o en el lab.
2. **¿Qué es Wireshark?** → Analizador de protocolos de red (sniffer): captura paquetes en vivo desde una interfaz de red y los decodifica capa por capa (Ethernet, IP, TCP/UDP, HTTP, DNS...). Es multiplataforma (Windows, Linux, macOS).
3. **¿Qué significa que una tarjeta de red esté en modo promiscuo?**
   → Normalmente la NIC solo procesa las tramas dirigidas a su MAC (o broadcast/multicast). En **modo promiscuo**, la NIC captura TODAS las tramas que pasan por el medio físico (aunque no vayan a ella). Wireshark usa esto para ver todo el tráfico del segmento.

### 3.2 Video 1 (máx. 5 min): interfaz y filtros

Explicar y mostrar:
- **Ventana principal**: lista de paquetes (packet list), detalle del paquete (packet details) y bytes (packet bytes).
- **Barra de filtros**: ejemplos:
  - `ip.addr == 10.2.78.69` — tráfico de una IP
  - `tcp.port == 443` — tráfico HTTPS
  - `http.request.method == "GET"` — peticiones GET
  - `icmp` — solo pings
- **Iniciar/detener captura** (el tiburón), guardar captura (.pcapng).

### 3.3 Captura real: scielo.org.co

1. Abrir Wireshark → doble clic en la interfaz de red activa (Wi-Fi o Ethernet).
2. Abrir el navegador → visitar `http://www.scielo.org.co`.
3. Volver a Wireshark → detener captura (cuadradito rojo).
4. Filtrar `http.request.method == "GET"` (o `http`) → localizar un paquete GET.
5. **Analizar la encapsulación** en la vista de detalle (capas de abajo hacia arriba):
   - **Frame** (trama completa)
   - **Ethernet II**: MAC origen/destino (capa 2)
   - **Internet Protocol**: IP origen/destino (capa 3)
   - **TCP**: puertos origen/destino (capa 4)
   - **HTTP**: la petición GET (capa de aplicación)
6. **Screenshots** de: la captura con el filtro, el paquete GET expandido capa por capa.

### 3.4 Video 2 (máx. 7 min): hallazgos

Explicar la captura de scielo.org.co, la encapsulación vista, y las diferencias entre los paquetes. (La parte de "3 recursos web" es para grupos de tres — no aplica.)

---

## 4. Network Cards

### 4.1 Dispositivos físicos

Reunir de la escuela y de cada integrante (mínimo 3 dispositivos por integrante + los de la escuela):
desktop, laptop, smartphone, tablet, consola, etc.

Para cada dispositivo, anotar:

| Campo | Dónde verlo (Windows) | Dónde verlo (Android/iPhone) |
|---|---|---|
| Fabricante y modelo de la NIC | `ipconfig /all` (descripción del adaptador) | Ajustes → Acerca del teléfono → Estado / Dirección MAC |
| Velocidad | `netsh interface show interface` | Ajustes Wi-Fi → detalles |
| MAC | `ipconfig /all` (Physical Address) | Ajustes → Estado |
| IPv4 | `ipconfig /all` | Ajustes → Wi-Fi → detalles |
| IPv6 | `ipconfig /all` | Ajustes → Wi-Fi → detalles |
| Bytes TX/RX | `netstat -e` | (difícil en móvil; usar ajustes de datos o apps) |
| Wi-Fi: velocidad + SSID | `netsh wlan show interfaces` | Ajustes Wi-Fi (red conectada) |

Comando rápido en Windows (todo junto):
```powershell
ipconfig /all
netstat -e
netsh wlan show interfaces
```

### 4.2 VMs (2 de las nuestras) y comparación

Comparar con **slackware-15.0** y **solaris-11.4** (datos ya conocidos del Lab 01):

**Slackware:**
```bash
ip addr show eth0        # MAC + IPv4 (10.2.78.64/16 + alias NAT 10.0.2.15)
ip -6 addr show eth0     # IPv6
cat /sys/class/net/eth0/address   # MAC
```
**Solaris:**
```bash
ipadm show-addr          # IPs (10.2.78.65/16, 10.0.2.15/24)
dladm show-phys          # NIC virtual (e1000g0)
```
**Datos esperados (Lab 01):** Slackware = VBOX NIC (MAC 08:00:27:...), IPv4 10.2.78.64;
Solaris = e1000g0, IPv4 10.2.78.65. Las VMs usan **NIC virtuales de VirtualBox** (82540EM / e1000g0) —
comparar con las físicas del host (Realtek/Intel) y anotar diferencias de velocidad y MAC.

---

## 5. Shell Programming — Unix (en Slackware 15.0)

> Loguearse: `ssh -i .ssh/vagrant.key -p 2222 vagrant@127.0.0.1` → `su -` (root/vagrant).
> Documentar cada script con comentarios (el código se evalúa).

### 5.1 Script "ls" con menú (`mi_ls.sh`)

**Requisitos:**
- Listar archivos de un directorio dado, **incluidos los ocultos**.
- Ordenar y agrupar contando:
  - Más recientes (cuántos comparten fecha)
  - Más antiguos (cuántos comparten fecha)
  - Tamaño mayor→menor (cuántos comparten tamaño)
  - Tamaño menor→mayor (cuántos comparten tamaño)
  - Tipo (Archivo/Directorio) (cuántos de cada tipo)
- Filtros: empieza con / termina con / contiene una cadena.
- Opción: solo el directorio o incluir subdirectorios (recursivo).
- Menú que **se mantiene hasta salir**, `clear` antes de mostrar, y **paginación** si la salida es larga.

**Comandos clave para armarlo:**
```bash
ls -la "$dir"                                   # listado con ocultos
ls -lat "$dir"                                  # ordenados por fecha (recientes)
ls -latr "$dir"                                 # por fecha (antiguos)
ls -laS "$dir"                                  # por tamaño mayor->menor
ls -laSr "$dir"                                 # por tamaño menor->mayor
find "$dir" -maxdepth 1 -type f | wc -l         # contar archivos
find "$dir" -maxdepth 1 -type d | wc -l         # contar directorios
ls -la "$dir" | awk '{print $6" "$7}' | sort | uniq -c   # agrupar por fecha
ls -la "$dir" | awk '{print $5}' | sort | uniq -c         # agrupar por tamaño
ls -la "$dir" | grep "^d" | wc -l               # cuántos directorios
ls -la "$dir" | grep -v "^d" | wc -l            # cuántos archivos
find "$dir" -name "patron*"                     # empieza con
find "$dir" -name "*patron"                     # termina con
find "$dir" -name "*patron*"                    # contiene
find "$dir" -type f                             # recursivo (subdirectorios)
less / more                                     # paginación
```

**Estructura sugerida:**
```bash
#!/bin/bash
# mi_ls.sh - Listar archivos con orden/filtros (Lab 02)
clear
read -p "Directorio a analizar: " dir
while true; do
  clear
  echo "1) Más recientes   2) Más antiguos   3) Mayor tamaño"
  echo "4) Menor tamaño    5) Por tipo       6) Filtros"
  echo "0) Salir"
  read -p "Opción: " op
  case $op in
    1) ls -lat "$dir" | less ;;   # + contar con awk/sort/uniq
    # ... completar cada caso ...
    0) exit 0 ;;
  esac
done
```

### 5.2 Script de búsqueda y visualización (`buscar.sh`)

**Menú hasta salir:**
1. Buscar archivo (o parte del nombre) en un directorio → mostrar rutas + total de ocurrencias:
   ```bash
   find "$dir" -name "*$patron*" 2>/dev/null
   find "$dir" -name "*$patron*" | wc -l
   ```
2. Buscar palabra (o parte) dentro de un archivo → mostrar palabra, líneas y total:
   ```bash
   grep -n "$palabra" "$archivo"
   grep -c "$palabra" "$archivo"
   ```
3. Buscar archivo y luego la palabra DENTRO de cada archivo encontrado → línea + total por archivo:
   ```bash
   for f in $(find "$dir" -name "*$patron_archivo*"); do
     echo "== $f =="
     grep -n "$palabra" "$f"
     echo "Total: $(grep -c "$palabra" "$f")"
   done
   ```
4. Contar líneas de un archivo: `wc -l "$archivo"`
5. Primeras n líneas: `head -n "$n" "$archivo"`
6. Últimas n líneas: `tail -n "$n" "$archivo"`

### 5.3 Script de revisión de logs (`revisar_logs.sh`)

**Requisitos:** limpiar pantalla, menú con:
1. Mostrar las **últimas 15 líneas de 3 logs de actividad general**.
2. Filtrar esas 15 líneas por una palabra específica.

**Logs a usar (Slackware):**
```bash
/var/log/syslog      # actividad general del sistema
/var/log/messages    # mensajes del kernel y servicios
/var/log/secure      # autenticación (ssh, sudo)
```
```bash
tail -n 15 /var/log/syslog
tail -n 15 /var/log/messages
tail -n 15 /var/log/secure
tail -n 15 /var/log/syslog | grep "$palabra"
```

**Preguntas conceptuales a responder:**
- **¿Qué son los archivos de log?** → Registros donde el SO y los servicios guardan eventos (fecha, origen, mensaje). Sirven para diagnóstico, auditoría y seguridad.
- **¿Qué tipos de logs hay en los SO instalados?** → Slackware: syslog, messages, secure, dmesg/kernel; Solaris: `/var/adm/messages`; Windows: Visor de eventos (System, Security, Application — eventos 4624/4625 vistos en Lab 01).
- **¿Qué es syslog y qué define el estándar?** → Protocolo/estándar para logging (RFC 5424): define formato de mensaje (facilidad + severidad), transporte (UDP 514) y el servicio. Centraliza logs de distintos dispositivos.
- **¿Los logs encontrados siguen el estándar?** → Sí: Slackware/Solaris usan formato syslog (facilidad.severidad, timestamp, host, proceso[pid]: mensaje). Windows usa su propio formato (Event Log), que NO es syslog nativo (puede enviarse con un agente).

### 5.4 Script de creación de usuarios (`newuser` / `newgroup`)

**Formato pedido:**
```bash
$ newuser alice developers "Alice Developer" /home/alice /bin/bash 700 770 755
$ newgroup developers 1001
```

**`newgroup`** (script o función): crea grupo con GID explícito:
```bash
#!/bin/bash
# newgroup <nombre> <gid>
groupadd -g "$2" "$1" 2>/dev/null && echo "Grupo $1 creado (GID $2)" || echo "Error: ¿ya existe?"
```

**`newuser`**: crea usuario + grupo + home + permisos (700 al home, 770 y 755 a subdirs):
```bash
#!/bin/bash
# newuser <user> <group> "<full name>" <home> <shell> <perm_home> <perm_dir1> <perm_dir2>
user="$1"; grupo="$2"; nombre="$3"; home="$4"; shell="$5"
p1="$6"; p2="$7"; p3="$8"
# crear grupo si no existe
getent group "$grupo" >/dev/null || groupadd "$grupo"
# crear usuario con home
useradd -d "$home" -m -c "$nombre" -g "$grupo" -s "$shell" "$user"
chmod "$p1" "$home"
mkdir -p "$home/documentos" "$home/scripts"
chmod "$p2" "$home/documentos"
chmod "$p3" "$home/scripts"
echo "Usuario $user creado en $home (permisos $p1/$p2/$p3)"
```
> Probar con los usuarios del Lab 01 (claudia/john/fabian/diego) y documentar la salida.

---

## 6. Editor VI — Ejercicio del Himno

> En Slackware: `vi himno.txt` (o `vim`). Documentar CADA comando usado.

### 6.1 Crear el archivo

```bash
vi himno.txt
```
- `i` → modo inserción.
- Escribir el himno línea por línea (Enter al final de cada línea).
- `Esc` → volver a modo normal.

**HIMNO DE LA ESCUELA**
```
Estudiante, maestro la conquista
Será hacer con amor nuestra labor
Cultores de espíritu humanista
Unidad de intelecto y corazón.
Escuela de ingenio es nuestra casa
Libro abierto a nuestra universidad
Aquí perdura mientras todo pasa
Cimiento de la fe y la integridad.
Ofrecemos la mano al que tropieza
La hidalguía del diálogo al rival
Ofrecemos la duda y la certeza
Mediamos entre hierro y el cristal.
Escuela de ingenio es nuestra casa
Libro abierto a nuestra universidad
Aquí perdura mientras todo pasa
Cimiento de la fe y la integridad.
```

### 6.2 Operaciones pedidas (comandos VI)

| Paso | Acción | Comando VI |
|---|---|---|
| 1 | Guardar sin salir | `:w` |
| 2 | Reemplazar TODAS las 'a' del 1.er párrafo (líneas 1-4) por `-` | `:1,4s/a/-/g` |
| 3 | Reemplazar todas las "al" por `##` en todo el texto | `:%s/al/##/g` |
| 4 | Borrar una palabra | `dw` (sobre la palabra) |
| 5 | Borrar las últimas 4 líneas (13-16) de una | `:13,16d` (o `13,16d`) |
| 6 | Deshacer (undo) | `u` |
| 7 | Convertir la última línea a mayúsculas | ir a la línea (`G`) → `gUU` (o `:16s/.*/\U&/`) |
| 8 | Copiar las últimas 2 líneas del 2.º párrafo al final | ir a línea 7 (`7G`) → `yy` ×2 → `G` → `p` |
| 9 | Buscar "Escuela" | `/Escuela` (n = siguiente) |
| 10 | Ir a la línea 5 | `5G` (o `:5`) |
| 11 | Tabla resumen de comandos VI | (documentar en el informe) |
| 12 | Guardar y salir | `:wq` (o `ZZ`) |
| 13 | Reabrir y borrar las primeras 5 líneas | `vi himno.txt` → `:1,5d` |
| 14 | Salir sin guardar | `:q!` |

### 6.3 Tabla resumen de comandos VI (para el informe)

| Modo | Comando | Qué hace |
|---|---|---|
| Normal | `i` / `a` | Insertar antes / después del cursor |
| Normal | `Esc` | Volver al modo normal |
| Normal | `x` / `dw` | Borrar carácter / palabra |
| Normal | `dd` / `5dd` | Borrar línea / 5 líneas |
| Normal | `u` / `Ctrl+r` | Deshacer / rehacer |
| Normal | `yy` / `p` | Copiar línea / pegar |
| Normal | `G` / `5G` | Ir al final / línea 5 |
| Normal | `/palabra` | Buscar palabra |
| Comando | `:w` / `:q` / `:wq` / `:q!` | Guardar / salir / guardar y salir / salir sin guardar |
| Comando | `:%s/old/new/g` | Reemplazar en todo el archivo |
| Comando | `:1,4s/a/-/g` | Reemplazar en rango de líneas |
| Comando | `:13,16d` | Borrar rango de líneas |
| Comando | `:set number` | Mostrar números de línea |

---

## 7. Virtual Machine Deployment (proyecto semestral)

**Consigna:** 2 VMs de cada SO instalado, EXCEPTO Windows Server sin GUI (Core) y Android.
→ Faltan: **2.ª Slackware, 2.ª Solaris, 2.ª Windows GUI**.

**Forma más rápida — clonar en VirtualBox:**
```powershell
# Clonar con el disco (full clone)
VBoxManage clonevm "slackware-15.0" --name "slackware-15.0-b" --register --mode machine
VBoxManage clonevm "solaris-11.4" --name "solaris-11.4-b" --register --mode machine
VBoxManage clonevm "windows-server-gui" --name "windows-server-gui-b" --register --mode machine
```
> OJO: los clones tendrán la misma MAC/IP → **cambiarles la IP estática** (ej. 10.2.78.74/75/76)
> y regenerar MAC (`--macaddress1 auto`) para que no choquen en la misma red.

**Verificación pedida:**
```bash
# Desde cada VM: ping a las otras y a internet
ping -c 3 10.2.78.74    # entre VMs
ping -c 3 8.8.8.8       # internet (con config de casa: /root/casa.sh en Solaris)
```

---

## 8. File Sharing — Servidor SMB/SAMBA en Solaris

**Objetivo:** configurar Solaris como servidor de archivos SMB y compartir con Slackware y Windows.

### 8.1 Instalar SAMBA en Solaris

```bash
# Como root (o admin con pfexec)
pkg install -v samba          # instala el paquete SMB de Solaris
pfexec svcs -a | grep -i smb  # ver servicios smb/server, smb/client
```

### 8.2 Crear la carpeta compartida

```bash
mkdir -p /export/compartido
# crear grupo y usuario SMB (usar uno del lab, ej. claudia)
groupadd shared 2>/dev/null
useradd -d /export/compartido/claudia -m -g shared claudia 2>/dev/null || true
chown -R claudia:shared /export/compartido
chmod 770 /export/compartido
```

### 8.3 Configurar SMB (Solaris usa SMF, no smb.conf clásico)

Solaris 11 gestiona SMB con SMF: `svc:/network/smb/server`.
```bash
# Activar el servidor SMB
pfexec svcadm enable svc:/network/smb/server
pfexec smbadm join-workgroup -w WORKGROUP   # unirse al grupo de trabajo
# Crear usuario SMB (contraseña para el recurso)
pfexec smbadm create-user claudia
# Compartir la carpeta
pfexec zfs set sharesmb=name=compartido,ro=false rpool/export 2>/dev/null \
  || pfexec smbadm create-share -p /export/compartido compartido
pfexec smbadm show-share   # verificar
```

### 8.4 Probar desde Slackware

```bash
# Instalar cliente SMB si falta
slackpkg install smbfs  # o: installpkg /ruta/samba.txz
# Listar y montar
smbclient -L //10.2.78.65 -U claudia
mkdir -p /mnt/solaris
mount -t cifs //10.2.78.65/compartido /mnt/solaris -o username=claudia
# o con smbclient interactivo:
smbclient //10.2.78.65/compartido -U claudia
```

### 8.5 Probar desde Windows

1. Explorador de archivos → `\\10.2.78.65\compartido`
2. Usuario: `claudia` + contraseña SMB.
3. Probar crear/copiar un archivo desde Windows y verlo desde Slackware (y viceversa).

### 8.6 Documentar

- Capturas: compartir desde Solaris, montar desde Slackware, acceder desde Windows.
- Explicar: qué es SMB/CIFS (puerto 445/TCP), qué hace SAMBA (implementación libre de SMB),
  diferencia entre compartir en Unix (NFS) y Windows (SMB).

---

## Checklist final de entrega

- [ ] Pregunta 1.1: versión de Packet Tracer
- [ ] Video curso Packet Tracer (cap. 1-4, máx 5 min) — 2 integrantes
- [ ] Quiz PT Basics + screenshot (individual)
- [ ] Archivo `.pkt` del diagrama (individual) + respuestas de links sólidos/punteados
- [ ] Simulación ping RADIUS→DHCP con PDUs analizadas
- [ ] Wireshark instalado + respuestas (qué es, modo promiscuo)
- [ ] Video Wireshark interfaz/filtros (máx 5 min)
- [ ] Captura scielo.org.co + análisis paquete GET + screenshots
- [ ] Video hallazgos (máx 7 min)
- [ ] Tabla tarjetas de red (escuela + 3 dispositivos × integrante) + 2 VMs comparadas
- [ ] Script 1.1 `ls` con menú (documentado)
- [ ] Script 1.2 búsqueda (documentado)
- [ ] Script 1.3 logs + respuestas (qué son, tipos, syslog, estándar)
- [ ] Script 1.4 `newuser`/`newgroup` (documentado)
- [ ] Ejercicio VI completo + tabla resumen de comandos
- [ ] VMs clonadas (2.ª Slackware, 2.ª Solaris, 2.ª Windows GUI) con ping entre ellas e internet
- [ ] SAMBA en Solaris compartiendo con Slackware y Windows + evidencia

---

## Notas de estudio (conectar con el curso CCNA ITN)

- **Encapsulación (Módulo 3)**: lo que viste en Packet Tracer (PDU capa por capa) y Wireshark
  (Frame→Ethernet→IP→TCP→HTTP) es exactamente el concepto de encapsulación/desencapsulación.
- **Protocolos (Módulo 3)**: los mensajes del lab (ICMP, ARP, DNS, DHCP, HTTP) son protocolos;
  ARP resuelve IP→MAC (Módulo 9), ICMP es el ping (Módulo 13).
- **End/Intermediary devices (Módulo 1)**: hosts (PC, servers) = end devices; routers/switches =
  intermediary devices. El diagrama de PT los clasifica.
- **Números (Módulo 5)**: las MAC son hex (08:00:27:...), las IPs son decimal por octetos — por eso
  Wireshark muestra las dos formas.
