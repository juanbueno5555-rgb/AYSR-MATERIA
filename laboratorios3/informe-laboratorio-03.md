# Informe Laboratorio No. 03 — Plataforma base y protocolos de la capa de aplicación

**Asignatura:** [PENDIENTE: nombre de la asignatura]
**Grupo:** 2 estudiantes — Camilo Aguirre, Juan David Rangel
**Fecha:** 29/08/2026

---

## 1. Introducción

La infraestructura de TI de una empresa estándar incluye servicios como DNS, web, correo,
bases de datos y almacenamiento, ejecutados sobre servidores físicos y virtualizados,
interconectados mediante switches, dispositivos inalámbricos y routers con salida a Internet.

En este laboratorio se continúa con la preparación de los servidores de la infraestructura
montada en los laboratorios anteriores, enfocándose en:

1. La instalación y configuración del servicio de resolución de nombres **DNS** (BIND en
   Linux, rol DNS en Windows Server) sobre los dominios de prueba del grupo:
   `juan.com.it` y `camilo.org.uk`.
2. La programación de **Shell** en Solaris y Slackware: programación de tareas periódicas,
   un menú de administración de procesos y un script de recorrido del sistema de archivos.
3. La introducción a la **computación en la nube** con Amazon EC2: lanzamiento de una
   instancia, conexión SSH y administración básica de almacenamiento EBS.

## 2. Marco teórico

### 2.1 DNS (Domain Name System)

El DNS es el servicio que traduce nombres de dominio legibles por personas a direcciones
IP (y viceversa). En un entorno empresarial es un servicio fundamental: permite acceder a
los servidores por nombre en lugar de por dirección IP, independientemente de cambios de
direccionamiento.

**Registros DNS principales:**

| Registro | Función |
|---|---|
| **A** | Asocia un nombre de host con una dirección IPv4. |
| **AAAA** | Asocia un nombre de host con una dirección IPv6. |
| **NS** | Indica los servidores de nombres autoritativos para una zona (Name Server). |
| **MX** | Indica el servidor de correo (Mail eXchange) de un dominio, con prioridad. |
| **CNAME** | Alias canónico: redirige un nombre a otro nombre canónico. |
| **SOA** | Start of Authority: cabecera de la zona con el servidor primario, el contacto
  administrativo y el número de serie (para replicación). |

**Arquitectura primario/secundario:** el servidor primario (maestro) posee la copia
maestra de la zona. Los servidores secundarios (esclavos) obtienen copias mediante
transferencias de zona desde el primario. Esto brinda redundancia: si uno cae, los demás
siguen resolviendo.

**Servidores raíz:** para resolver dominios externos, un servidor DNS necesita conocer los
servidores raíz del dominio `.` (archivo `named.ca` o *hints*), o delegar la resolución a
un *forwarder*.

### 2.2 Shell y programación de tareas

- **cron**: servicio que ejecuta tareas periódicamente según una tabla de frecuencias
  (`minuto hora día-mes mes día-semana`, p. ej. `* * * * *`).
- **Administración de procesos**: visualización (nombre, PID, % memoria, % CPU),
  búsqueda, terminación y re-arranque de procesos.
- **Recorrido del sistema de archivos**: listado recursivo de archivos con filtros de
  tamaño y cantidad.

### 2.3 Computación en la nube (Amazon EC2)

Amazon Elastic Compute Cloud (EC2) provee capacidad de cómputo escalable bajo demanda en
la nube de AWS: se lanzan servidores virtuales (instancias) configurando el sistema
operativo (AMI), el tipo de instancia, el par de llaves SSH, la red (VPC) y el
almacenamiento (EBS). El pago es por uso (modelo *pay-as-you-go*), con un nivel gratuito
(*Free Tier*) apto para prácticas académicas.

## 3. Desarrollo del tema

### 3.1 Instalación y configuración del servicio DNS (BIND / rol DNS)

#### 3.1.1 Distribución de servidores DNS del grupo

Según la guía, para un grupo de 2 estudiantes se configuran los dominios 1 y 2 con los
nombres del grupo: `juan.com.it` (reemplazo de *student1.com.it*) y `camilo.org.uk`
(reemplazo de *student2.org.uk*). La distribución acordada es:

| Servidor | `juan.com.it` | `camilo.org.uk` |
|---|---|---|
| Solaris (`solaris-11.4`) | **Primario** | Secundario |
| Slackware (`slackware-15.0`) | Secundario | **Primario** |
| Windows Server GUI (`windows-server-gui`) | Secundario | — |
| Windows Server Core (`windows-server-core`) | — | Secundario |

Todos los servidores comparten la red interna virtual `lab-uni` (192.168.82.0/24) para la
transferencia de zonas y las pruebas de resolución entre máquinas:

| VM | IP interna (intnet `lab-uni`) | IP red universidad | SO / rol |
|---|---|---|---|
| Slackware | 192.168.82.10 | 10.2.78.74 | BIND master `camilo.org.uk` |
| Solaris | 192.168.82.11 | 10.2.78.75 | BIND master `juan.com.it` |
| Windows GUI | 192.168.82.13 | 10.2.78.76 | Rol DNS, secundario `juan.com.it` |
| Windows Core | 192.168.82.12 | 10.2.78.77 | Rol DNS, secundario `camilo.org.uk` |

[PENDIENTE: confirmar el rango IPv4/IPv6 "asignado al inicio del semestre" y los nombres
concretos de servidores y alias usados en las zonas.]

#### 3.1.2 Configuración en Linux Slackware (primario de `camilo.org.uk`)

**Instalación:** el paquete BIND se instaló y verificó con pkgtools. El binario quedó en
`/usr/sbin/named` y el servicio se encontraba en ejecución (29/08/2026).

**Archivo `/etc/named.conf`:**

```
options {
	directory "/etc/DNS";
	dnssec-validation no;
};

zone "." IN {
	type hint;
	file "named.ca";
};

zone "0.0.127.in-addr.arpa" IN {
	type master;
	file "127.0.0.rev";
	allow-update { none; };
};

zone "camilo.org.uk" IN {
	type master;
	file "camilo.org.uk.hosts";
	allow-transfer { 192.168.82.11; 192.168.82.12; };
	notify yes;
};

zone "juan.com.it" IN {
	type slave;
	masters { 192.168.82.11; };
	file "juan.com.it.slave";
};
```

**Zona maestra `camilo.org.uk`** — archivo `/etc/DNS/camilo.org.uk.hosts`:

```
; camilo.org.uk.hosts - Zona camilo.org.uk (Lab 03)
;
$TTL 86400
$INCLUDE named.soa

; Name Server
@		IN NS	dns1.camilo.org.uk.

; localhost
localhost.camilo.org.uk.	IN A	127.0.0.1

; Servers con IPv4 (rango de la universidad)
dns1.camilo.org.uk.	IN A	10.2.78.74
srv1.camilo.org.uk.	IN A	10.2.78.75
srv2.camilo.org.uk.	IN A	10.2.78.76

; Servers con IPv6
dns1.camilo.org.uk.	IN AAAA	2001:db8:2::74
srv2.camilo.org.uk.	IN AAAA	2001:db8:2::76

; Aliases (2 a servers IPv4 + 1 a server IPv6)
www.camilo.org.uk.	IN CNAME	srv1.camilo.org.uk.
mail.camilo.org.uk.	IN CNAME	dns1.camilo.org.uk.
v6.camilo.org.uk.	IN CNAME	srv2.camilo.org.uk.
```

SOA (archivo `named.soa`, incluido con `$INCLUDE`):

```
@ IN SOA dns1.camilo.org.uk. root.camilo.org.uk. (
	2026082801 ; Serial yyyymmddxx
	10800      ; Refresh 3h
	3600       ; Retry 1h
	604800     ; Expire 1sem
	86400 )    ; Negative TTL 1d
```

**Archivo de servidores raíz `/etc/DNS/named.ca`:**

```
; named.ca - Root name servers (hints)
.			3600000	IN	NS	A.ROOT-SERVERS.NET.
A.ROOT-SERVERS.NET.	3600000	IN	A	198.41.0.4
A.ROOT-SERVERS.NET.	3600000	IN	AAAA	2001:503:BA3E::2:30
B.ROOT-SERVERS.NET.	3600000	IN	A	170.247.170.2
C.ROOT-SERVERS.NET.	3600000	IN	A	192.33.4.12
```

#### 3.1.3 Configuración en Solaris (primario de `juan.com.it`)

**Instalación:** servicio SMF `svc:/network/dns/server` en estado `online`; binario
`/usr/sbin/named`.

**Archivo `/etc/named.conf`:**

```
options {
	directory "/etc/inet/DNS";
	dnssec-validation no;
};

zone "." IN {
	type hint;
	file "named.ca";
};

zone "0.0.127.in-addr.arpa" IN {
	type master;
	file "127.0.0.rev";
	allow-update { none; };
};

zone "juan.com.it" IN {
	type master;
	file "juan.com.it.hosts";
	allow-transfer { 192.168.82.10; 192.168.82.13; };
	notify yes;
};

zone "camilo.org.uk" IN {
	type slave;
	masters { 192.168.82.10; };
	file "camilo.org.uk.slave";
};
```

**Zona maestra `juan.com.it`** — archivo `/etc/inet/DNS/juan.com.it.hosts`:

```
; juan.com.it.hosts - Zona juan.com.it (Lab 03)
;
$TTL 86400
$INCLUDE named.soa

; Name Server
@		IN NS	dns1.juan.com.it.

; localhost
localhost.juan.com.it.	IN A	127.0.0.1

; Servers con IPv4 (rango de la universidad)
dns1.juan.com.it.	IN A	10.2.78.75
srv1.juan.com.it.	IN A	10.2.78.74
srv2.juan.com.it.	IN A	10.2.78.76

; Servers con IPv6
dns1.juan.com.it.	IN AAAA	2001:db8:1::75
srv2.juan.com.it.	IN AAAA	2001:db8:1::76

; Aliases (2 a servers IPv4 + 1 a server IPv6)
www.juan.com.it.	IN CNAME	srv1.juan.com.it.
mail.juan.com.it.	IN CNAME	dns1.juan.com.it.
v6.juan.com.it.	IN CNAME	srv2.juan.com.it.
```

SOA (archivo `named.soa`, incluido con `$INCLUDE`):

```
@ IN SOA dns1.juan.com.it. root.juan.com.it. (
	2026082801 ; Serial yyyymmddxx
	10800      ; Refresh 3h
	3600       ; Retry 1h
	604800     ; Expire 1sem
	86400 )    ; Negative TTL 1d
```

**Archivo de servidores raíz `/etc/inet/DNS/named.ca`:** mismo contenido que el de Slackware:
A.ROOT-SERVERS.NET (198.41.0.4 + AAAA 2001:503:BA3E::2:30), B.ROOT-SERVERS.NET
(170.247.170.2) y C.ROOT-SERVERS.NET (192.33.4.12).

#### 3.1.4 Configuración de los secundarios (completada 01/09/2026)

- **Windows Server GUI** — secundario de `juan.com.it`:
  - Instalación del rol **DNS** completada (29/08/2026, sin reinicio requerido).
  - Zona secundaria `juan.com.it` creada apuntando al maestro Solaris `192.168.82.11`
    (verificado: `ZoneType Secondary`, MasterServers 192.168.82.11, servicio `DNS`
    `Running`/`Automatic`).
- **Windows Server Core** — secundario de `camilo.org.uk`:
  - Instalación del rol **DNS** completada (29/08/2026, sin reinicio requerido).
  - Zona secundaria `camilo.org.uk` creada apuntando al maestro Slackware `192.168.82.10`
    (verificado: `ZoneType Secondary`, MasterServers 192.168.82.10, servicio `DNS`
    `Running`/`Automatic`).
- **Slackware** — secundario de `juan.com.it` y **Solaris** — secundario de `camilo.org.uk`:
  - Slackware: zona `juan.com.it` `type slave` con `masters { 192.168.82.11; }`
    (maestro Solaris), `allow-transfer` y `notify` habilitados en el maestro.
  - Solaris: zona `camilo.org.uk` `type slave` con `masters { 192.168.82.10; }`
    (maestro Slackware), `allow-transfer` y `notify` habilitados en el maestro.
  - Transferencia verificada: ambos esclavos resuelven los registros de la zona del otro
    (Slackware resuelve `srv1.juan.com.it` → 10.2.78.74; Solaris resuelve
    `srv1.camilo.org.uk` → 10.2.78.75), serial `2026082801` coincidente.

#### 3.1.5 Respuestas a las preguntas de la guía (parte DNS)

**4. ¿Qué son los registros A y AAAA en el archivo de servidores raíz?**
Los registros A y AAAA del archivo de servidores raíz (`named.ca`) contienen las direcciones
IPv4 (A) e IPv6 (AAAA) de los servidores raíz del DNS. El servidor las usa para iniciar la
resolución iterativa de dominios que no están en sus zonas locales: consulta un servidor
raíz, que le indica los servidores autoritativos del TLD, y así sucesivamente.

**5. ¿Qué son los registros NS, MX, A y CNAME en el archivo del dominio particular?**
- **NS**: declara qué servidor(es) de nombres son autoritativos para la zona.
- **MX**: declara el servidor de correo del dominio, con prioridad numérica.
- **A**: asocia un nombre de host canónico con su dirección IPv4.
- **CNAME**: define un alias que apunta a un nombre canónico (no a una IP).

**6. Revisión de logs** — estado registrado en `/var/svc/log/network-dns-server:default.log` (Solaris) y
`/var/log/messages` (Slackware) sin errores de carga de zona en el arranque verificado (01/09/2026).

**7. Pruebas con nslookup en un cliente** — [PENDIENTE: video de máximo 5 minutos y
resultados de los puntos A–G: propósito de nslookup, pruebas contra el DNS propio, cambio
al DNS de la escuela (10.2.65.1), `set type=NS`, `set debug`, `set type=A`, `set q=MX`.]

**8. Prueba en el propio servidor DNS** — verificado el 01/09/2026 en ambos servidores
básicos (evidencias en `evidencias/server-propio-slackware.txt` y `server-propio-solaris.txt`):
- **Slackware** (`nslookup camilo.org.uk 127.0.0.1`): SOA `dns1.camilo.org.uk`, serial
  `2026082801`; `www.camilo.org.uk` → CNAME `srv1.camilo.org.uk` → `10.2.78.75`;
  `srv1.juan.com.it` (zona esclava) → `10.2.78.74`. IP final: `192.168.82.10` (intnet).
- **Solaris** (`nslookup juan.com.it 127.0.0.1`): SOA `dns1.juan.com.it`, serial
  `2026082801`; `srv1.juan.com.it` → `10.2.78.74`; `www.juan.com.it` → CNAME → `10.2.78.74`;
  `srv1.camilo.org.uk` (zona esclava) → `10.2.78.75`. IP final: `192.168.82.11` (intnet).
- **Explicación**: `nslookup` funciona en el propio servidor porque el demonio BIND escucha
  en `127.0.0.1` (interfaz loopback) además de las IPs físicas, y porque el servidor es
  autoritativo para sus zonas: responde de forma *authoritative* sin consultar a nadie.
  Las zonas esclavas responden igual porque se transfirieron desde el maestro y el servidor
  las sirve en modo autoritativo; lo único necesario es que el archivo de zona exista y el
  serial coincida con el maestro (verificado: serial `2026082801` en las dos zonas).

**9. Activación del servicio al arranque** — verificado el 01/09/2026
(evidencia en `evidencias/servicio-boot.txt`):
- Slackware: script `/etc/rc.d/rc.bind` presente y ejecutable (`rwxr-xr-x`), demonio
  activo: `/usr/sbin/named -u named`.
- Solaris: SMF `svc:/network/dns/server:default` con `enabled=true` y `online`
  (persistente entre reinicios; manifest `/lib/svc/manifest/network/dns/server.xml`).
- Windows Core y GUI: servicio `DNS` en estado `Running` con arranque `Automatic`;
  zonas secundarias activas (`camilo.org.uk` ← 192.168.82.10 en Core, `juan.com.it` ←
  192.168.82.11 en GUI).

**10. Configuración mostrada al instructor** — pendiente de sustentación.

### 3.2 Programación Shell (Solaris y Slackware)

Según la guía, el grupo de 2 estudiantes debe escribir los tres scripts para Solaris y
Slackware (no requiere PowerShell).

#### 3.2.1 (a) Programación de tareas periódicas — `schedult-task-script.sh`

Permite configurar una tarea para ejecución periódica; la tarea y su frecuencia se reciben
por línea de comandos, sin solicitudes interactivas:

```
solaris# ./schedult-task-script.sh [frecuencia]
solaris# ./schedult-task-script.sh * * * * *
```

[PENDIENTE: código del script, pruebas de ejecución y verificación con `crontab -l`.]

#### 3.2.2 (b) Menú de administración de procesos

Menú interactivo con opciones para:
- Mostrar los procesos en ejecución (nombre, PID, % memoria, % CPU).
- Buscar un proceso por nombre y mostrar su información completa.
- Matar un proceso.
- Reiniciar un proceso.
- Salir del menú.

[PENDIENTE: código del script y capturas del menú con cada opción.]

#### 3.2.3 (c) Recorrido del sistema de archivos — `files-script.sh`

Recorre recursivamente el árbol desde un directorio dado y muestra los `n` archivos más
pequeños menores a un tamaño máximo, con nombre, ruta y tamaño:

```
slackware# ./files-script.sh [no_files] [max_size]
slackware# ./files-script.sh 10 1GB
```

[PENDIENTE: código del script, manejo de unidades (B, KB, MB, GB) y salida de ejemplo.]

### 3.3 Cloud — Amazon EC2

#### 3.3.1 Preguntas generales

**1. ¿Cuáles son las principales características de Amazon EC2?**
[PENDIENTE: respuesta desarrollada.]
**2. ¿Qué servicios se pueden usar con Amazon EC2?**
[PENDIENTE: respuesta desarrollada.]

#### 3.3.2 Lanzamiento y conexión a la instancia

[PENDIENTE: documento con pantallazos del procedimiento: selección de región, nombre,
AMI Free Tier (Amazon Linux), tipo de instancia Free Tier, key pair (.pem), VPC/security
group (SSH), storage, estado *pending → running*, status checks y conexión:

```
ssh -i key-pair-name.pem ec2-user@ec2-XXXX.us-east-2.compute.amazonaws.com
```]

#### 3.3.3 Next steps (preguntas a responder)

1. Diferencia entre detener (*stop*), terminar (*terminate*) y reiniciar (*restart*) una
   instancia EC2. [PENDIENTE]
2. Rol de la AMI al lanzar una instancia. [PENDIENTE]
3. Casos en que conviene una AMI distinta a Amazon Linux. [PENDIENTE]
4. Agregar y adjuntar volúmenes; diferencia entre EBS y almacenamiento ephemeral. [PENDIENTE]
5. Ejecución de comandos remotos sin SSH (Systems Manager Run Command). [PENDIENTE]
6. Pasos para adjuntar un volumen EBS adicional a una instancia Linux existente. [PENDIENTE]
7. Qué ocurre con los datos de un volumen EBS al detener o terminar la instancia. [PENDIENTE]
8. ¿El Shell configurado en Slackware funciona en la instancia? Qué habría que cambiar;
   probar su funcionamiento. [PENDIENTE: prueba en la instancia]

## 4. Uso y aplicaciones

- El DNS empresarial permite nombrar servidores de forma estable y redundante
  (primario/secundario), base para servicios como web y correo.
- La programación de tareas y la administración de procesos por Shell son la base de la
  operación administrativa de servidores Linux/UNIX sin interfaz gráfica.
- EC2 permite aprovisionar servidores de prueba y producción bajo demanda, con
  escalamiento horizontal y pago por uso.

## 5. Conclusiones

[PENDIENTE: redactar al cierre del laboratorio.]

## 6. Bibliografía

- Guía oficial del laboratorio: *Laboratory No.03 — Base Platform and Application Layer
  Protocols* (PDF).
- [PENDIENTE: añadir documentación de BIND, nslookup, cron y AWS EC2 consultada.]

---

## Apéndice A — Evidencia

[PENDIENTE: capturas de pantalla (configuraciones, logs, nslookup, scripts, consola AWS) con
numeración consistente; transcribir comandos y salidas completos.]

## Apéndice B — Configuraciones finales

[PENDIENTE: archivos de configuración finales de los 4 servidores DNS y salidas de
verificación (`nslookup`, `dig`, `Get-DnsServerZone`).]