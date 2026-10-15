# Entender lo que ves — comandos del Lab 03 explicados

**Asignatura:** AYSR — Laboratorio No.03 (DNS, Shell, EC2)
**Grupo:** Camilo Aguirre — Juan David Rangel
**Uso:** guía de estudio interna. Explica **qué significa la salida** de cada comando, no solo cómo se escribe.

---

## 0. El concepto que más confunde: ¿cliente o servidor?

En este lab **cada máquina es las DOS cosas al mismo tiempo**: corre un servidor DNS *y* actúa como cliente.

| Rol | Dónde vive la config | Qué significa |
|---|---|---|
| **Cliente** (quién pregunta) | `/etc/resolv.conf` (Linux) o la config del adaptador (Windows) | "A qué servidor le pido que resuelva nombres" |
| **Servidor** (quién responde) | `/etc/named.conf` + archivos de zona (Linux) o rol DNS (Windows) | "De qué zonas soy dueño y qué datos tengo" |

**Las dos reglas que explican TODO:**

1. `nameserver 127.0.0.1` significa *"me pregunto a mí mismo"* → es la prueba del **punto 8** (en el propio servidor).
2. Poner la **IP de otra máquina** como resolver → es la prueba del **punto 7** (un cliente usando nuestro DNS).

### ¿Por qué a veces responde "el local" y no "el servidor DNS"?

Porque en esa prueba **el local ES el servidor DNS**. No son máquinas distintas: es la misma.

- Para `camilo.org.uk`, Slackware es **maestro** → dueño de los datos.
- Para `juan.com.it`, Slackware es **esclavo** → BIND guardó una **copia completa** de la zona (transferida una vez) y la sirve como autoritativa. Un esclavo **no reenvía** la consulta al maestro: responde con su copia.
- Por eso, cuando preguntás desde Slackware, **no sale a la red**: ya tiene la respuesta adentro.

`nslookup` muestra **a quién le preguntaste**, no "de dónde vinieron los datos":

```
Slackware (misma máquina):   Server: 127.0.0.1        <- me pregunté a mí mismo
Windows GUI (otra máquina):  Server: 192.168.82.10    <- le pregunté a Slackware
```

---

## 1. DNS

### 1.1 `nslookup srv1.camilo.org.uk`
```
Server:   127.0.0.1
Address:  127.0.0.1#53

Name:   srv1.camilo.org.uk
Address: 10.2.78.75
```
**Qué ves:**
- **Primer bloque (`Server`/`Address`)** = *quién contestó*. `127.0.0.1` es el `named` local (así quedó en `resolv.conf`). El `#53` es el **puerto** de DNS.
- **Segundo bloque (`Name`/`Address`)** = *la respuesta*: el registro **A** (nombre → IPv4).

**Por qué:** al estar el resolver en `127.0.0.1`, la consulta fue al servidor local, que es autoritativo de la zona y responde de memoria.

**Dato clave:** si aparece `Non-authoritative answer` significa que quien contestó **no es dueño** de la zona y respondió desde **caché** (no es falso, es una copia reciente). Si el dueño contesta, esa línea **no aparece**.

### 1.2 `nslookup srv1.juan.com.it` (desde Slackware)
```
Name:   srv1.juan.com.it
Address: 10.2.78.74
```
**Por qué funciona sin preguntarle a Solaris:** Slackware es **esclavo** de `juan.com.it`. Cuando un esclavo carga una zona, la sirve como autoritativa. Ese es el objetivo de la replicación: **cualquiera de los servidores puede responder**, incluso si el primario está caído.

### 1.3 `nslookup www.camilo.org.uk` (un alias)
```
www.camilo.org.uk  canonical name = srv1.camilo.org.uk.
Name:   srv1.camilo.org.uk
Address: 10.2.78.75
```
**Por qué salen DOS cosas:** `www` es un **CNAME** (alias). El servidor devuelve el nombre canónico (`www` → `srv1`) **y** el registro A del destino, en el mismo mensaje. Se pidió un nombre; se obtuvo el nombre real + la IP.

### 1.4 `nslookup www.google.com` (dominio externo)
Salida esperada (con internet): respuesta, normalmente **`Non-authoritative answer`**.
**Por qué:** el `named` local **no es dueño** de `google.com`, así que actúa de **recursor**: consulta las raíces (definidas en `named.ca`), luego el TLD `.com`, luego los servidores de Google. Guarda el resultado en **caché** y lo entrega. Al venir de caché → "no autoritativa".

### 1.5 `nslookup -type=NS juan.com.it`
```
juan.com.it  nameserver = dns1.juan.com.it.
```
**Por qué:** se pidió el registro **NS** (qué servidores son autoritativos), no una IP. Devuelve el nombre del servidor.

### 1.6 `nslookup -type=MX juan.com.it`
```
juan.com.it   No answer
```
**Por qué NO es un error:** el nombre **existe**, pero no tiene registro de ese **tipo** (MX = correo, que está comentado en la zona). Distinto de:
- **`No answer`** = el nombre existe, ese tipo de registro no.
- **`NXDOMAIN`** = el nombre **no existe** (p. ej. contra el DNS de la escuela, que no conoce `juan.com.it`).

### 1.7 `set debug`
**Por qué es largo:** baja el detalle al máximo y muestra el **paquete DNS completo**: la sección `QUESTIONS` (qué se preguntó, con tipo **A y AAAA**), `ANSWERS`, los *flags* y el SOA. Es la radiografía de la consulta.

### 1.8 `cat /etc/named.conf`
**Qué ves y por qué:**
| Bloque | Significa |
|---|---|
| `options { directory "/etc/DNS"; }` | Dónde están los archivos de zona |
| `zone "." { type hint; file "named.ca"; }` | **Raíces**: sin esto no resuelve dominios externos |
| `zone "camilo.org.uk" { type master; }` | **Soy el dueño** de esta zona |
| `zone "juan.com.it" { type slave; masters {...}; }` | **Copio** esta zona de otro servidor |
| `allow-transfer { ... }` | Solo estas IPs pueden pedir la copia (AXFR) |
| `notify yes;` | Avisa a los esclavos apenas cambia la zona |

### 1.9 `ps -ef | grep named`
```
named  514  1  0 21:02 ?  /usr/sbin/named -u named
```
**Qué ves y por qué:**
- `514` = **PID** (identificador del proceso).
- `1` = **proceso padre** (init): lo levantó el sistema, no un usuario.
- `-u named` = **bajó privilegios** y corre como usuario `named`, **no como root**. Seguridad: si comprometen el DNS, no comprometen la máquina.

### 1.10 `svcs dns/server` (Solaris)
```
STATE    STIME   FMRI
online   ...     svc:/network/dns/server:default
```
**Por qué "online" NO es lo mismo que "arranca al boot":**
- `online` = está corriendo **ahora**.
- `enabled=true` = SMF lo levanta **solo en cada arranque**.
El punto 9 del lab pide lo segundo.

### 1.11 `nslookup` en Windows → `Server: UnKnown`
```
Server:  UnKnown
Address:  192.168.82.10
```
**Por qué dice "UnKnown":** Windows intenta mostrar el **nombre** del servidor DNS, y para eso hace una consulta inversa (PTR) sobre su IP. Como `192.168.82.10` no tiene registro inverso, no puede nombrarlo → "UnKnown". **Es cosmético, no un error.**

### 1.12 Comandos de Windows útiles
```powershell
Get-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -AddressFamily IPv4
#   -> a qué servidor DNS apunta el cliente (el lado "cliente")

Get-DnsServerZone -Name "juan.com.it"
#   -> ZoneType: Secondary  (el lado "servidor": es esclavo de esa zona)

Resolve-DnsName srv1.juan.com.it -Type A
#   -> equivalente moderno de nslookup (cliente DNS de Windows)
```

---

## 2. Shell

### 2.1 `schedult-task-script.sh * * * * *` y luego `crontab -l`
```
* * * * * /usr/local/bin/mi-script.sh
```
**Por qué 5 asteriscos:** son los **5 campos de tiempo** de cron:

```
minuto  hora  día-mes  mes  día-semana   comando
  *      *       *      *        *        /ruta/script.sh
```
`* * * * *` = "todos los minutos". Por eso el script "corre solo".
**Ojo Solaris:** el cron viejo **no soporta `*/N`**; usar `* * * * *` o expandir el rango (`0-59/1`).

### 2.2 `menu-procesos.sh` → opción "listar"
**Por qué esas columnas:** el script pide `ps` con formato propio (`-eo` en Linux / `-efo` en Solaris) para mostrar exactamente lo que pide la guía: **nombre, PID, %memoria, %CPU**.

### 2.3 `menu-procesos.sh` → buscar / matar / reiniciar
- **Buscar:** filtra `ps` por el nombre que ingresaste.
- **Matar:** `kill <PID>` envía `SIGTERM` (pide que termine); `kill -9` es `SIGKILL` (lo termina sí o sí).
- **Reiniciar:** `kill -CONT <PID>` reanuda un proceso detenido (`SIGCONT`).

### 2.4 `files-script.sh 10 1GB`
**Qué ves:** nombre, ruta y tamaño de los 10 archivos más pequeños ≤ 1 GB.
**Por qué:** se le pasaron 2 argumentos → `$1`=10 (cantidad), `$2`=1GB (tamaño máximo). Internamente: `find` recorre (con subdirectorios), `du` mide, `sort -n` ordena por tamaño y `head -n 10` corta los primeros.

---

## 3. EC2

### 3.1 `ssh -i lab03-key.pem ec2-user@ec2-...`
**Por qué pregunta "Are you sure you want to continue connecting":** es **TOFU** (*trust on first use*). La primera vez no conoce la huella del host, te la muestra para que la verifiques y la guarda en `known_hosts`. Si la huella no coincide con la de la consola (*Get system log*), puede haber un **man-in-the-middle**.
**Por qué el usuario es `ec2-user`:** es el usuario por defecto de la AMI de **Amazon Linux** (cada distro trae el suyo: `ubuntu` en Ubuntu, etc.).

### 3.2 `lsblk` / montaje de un EBS
**Qué ves:** los discos (`xvda` raíz, `xvdf` el nuevo).
**Por qué:** el volumen EBS se adjunta **en caliente**; el SO lo ve como un disco nuevo. Pasos: `mkfs.ext4 /dev/xvdf` → `mount` → `/etc/fstab` para que persista.

### 3.3 STOP vs TERMINATE vs RESTART
| Acción | Qué pasa con el disco EBS raíz |
|---|---|
| **Stop** | La instancia se apaga; el EBS **persiste**; se deja de facturar cómputo |
| **Terminate** | La instancia se **elimina**; el EBS raíz se borra (salvo protección) |
| **Restart** | Reinicia el SO en la misma instancia (cambios de kernel/config) |

**Ephemeral (instance store):** disco temporal ligado al host físico → **se pierde siempre** al detener/terminar.

---

## 4. Resumen de "por qué" en una línea

| Ves... | Porque... |
|---|---|
| `Server: 127.0.0.1` | El resolver está en la máquina local (prueba en el propio servidor, punto 8) |
| `Server: 192.168.82.10` | El cliente apunta al DNS de otra máquina (punto 7) |
| `Non-authoritative answer` | Contestó un recursor desde su **caché**, no el dueño de la zona |
| `No answer` | El nombre existe, pero no ese **tipo** de registro |
| `NXDOMAIN` | El nombre **no existe** para ese servidor |
| `canonical name =` | Es un **CNAME** (alias → nombre real) |
| `named -u named` | El servicio **bajó privilegios** (no corre como root) |
| `online` + `enabled=true` | Está activo **y** arranca al boot |
| `UnKnown` (nslookup Windows) | No hay registro inverso (PTR) para el nombre del servidor DNS |
