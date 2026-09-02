# Laboratorio 03 — Explicación completa y extendida: DNS, Shell y Amazon EC2

**Asignatura:** AYSR (Arquitectura de Sistemas y Redes)
**Grupo:** 2 estudiantes — Camilo Aguirre, Juan David Rangel
**Guía oficial:** *Laboratory No.03 — Base Platform and Application Layer Protocols*
**Última actualización:** 02/09/2026 (configuraciones verificadas en vivo por SSH)

---

## Índice

1. [Objetivo y contexto del laboratorio](#1-objetivo-y-contexto-del-laboratorio)
2. [Infraestructura del grupo](#2-infraestructura-del-grupo)
3. [Parte 1 — DNS: teoría completa](#3-parte-1--dns-teoría-completa)
4. [Parte 1 — DNS: los archivos de configuración explicados línea por línea](#4-parte-1--dns-los-archivos-de-configuración-explicados-línea-por-línea)
5. [Parte 1 — DNS: configuración de los secundarios Windows](#5-parte-1--dns-configuración-de-los-secundarios-windows)
6. [Parte 1 — DNS: pruebas realizadas y comportamiento esperado](#6-parte-1--dns-pruebas-realizadas-y-comportamiento-esperado)
7. [Parte 2 — Programación Shell: teoría y scripts](#7-parte-2--programación-shell-teoría-y-scripts)
8. [Parte 3 — Amazon EC2: teoría](#8-parte-3--amazon-ec2-teoría)
9. [Preguntas de la guía con respuesta desarrollada](#9-preguntas-de-la-guía-con-respuesta-desarrollada)
10. [Entregables, estado de avance y plan](#10-entregables-estado-de-avance-y-plan)
11. [Evidencias y archivos del repo](#11-evidencias-y-archivos-del-repo)
12. [Glosario rápido](#12-glosario-rápido)

---

## 1. Objetivo y contexto del laboratorio

### 1.1 Dónde estamos parados

En los laboratorios anteriores se construyó la infraestructura de la "empresa" virtual:
máquinas virtuales (Slackware 15.0, Solaris 11.4, Windows Server 2019 GUI y Core),
una red interna (`intnet lab-uni`), esquemas de direccionamiento para la universidad y
para casa (watchdogs de red), y servicios base como Samba (Lab 02).

Este laboratorio continúa con el **software base de los servidores**: el servicio de
resolución de nombres **DNS** (BIND en Linux, rol DNS en Windows), complementado con
**programación de Shell** (tareas periódicas, administración de procesos, recorrido del
sistema de archivos) y una primera experiencia con **computación en la nube** (Amazon EC2).

La guía menciona también **NTP** (Network Time Protocol, sincronización de reloj) en el
objetivo general, aunque las actividades concretas del lab se centran en DNS, Shell y EC2.

### 1.2 Reglas por tamaño de grupo

| Grupo | Dominios | Máquinas | Scripts |
|---|---|---|---|
| 2 estudiantes (este grupo) | Solo `student1.com.it` y `student2.org.uk` | Solaris, Slackware, Windows Server | Shell para Solaris y Slackware (sin PowerShell) |
| 3 estudiantes | Se agrega `student3.gov.jp` | Se agrega CentOS (reemplaza a Windows Server) | + PowerShell en Windows |
| 1 estudiante | — | — | Shell solo para Solaris |

El grupo JD+CA usa los dominios `juan.com.it` y `camilo.org.uk` (nombres reales que
reemplazan "student1" y "student2").

### 1.3 Qué se entrega al final

1. Configuración DNS completa en 3+ servidores con resolución interna y externa.
2. Respuestas a las preguntas 4-10 de la parte DNS.
3. Video de máximo 5 minutos con nslookup (puntos A-G).
4. Tres scripts Shell funcionando en Solaris y Slackware.
5. Preguntas respondidas de EC2 + instancia lanzada y probada por SSH
   (incluye probar el Shell del lab en la instancia).
6. Informe con evidencia (mismo formato autosuficiente de los labs 01 y 02).

---

## 2. Infraestructura del grupo

### 2.1 Las dos redes

| Red | Dirección | Para qué sirve |
|---|---|---|
| Red de la universidad | `10.2.0.0/16`, gateway y DNS `10.2.65.1`, **sin DHCP** | Cada VM tiene una IP estática visible en la red de la uni; SSH directo desde el PC; salida a Internet |
| Red interna virtual (`intnet lab-uni`) | `192.168.82.0/24` | Red privada SOLO entre las VMs (aislada del host): transferencias de zona DNS y pruebas de resolución entre servidores |

El direccionamiento estático se aplica con watchdogs internos (cada 60 s detectan el
gateway `10.2.65.1` y aplican la IP uni; si no responde, quedan en DHCP para casa).
Detalle: Slackware siempre cura sola su IP (estática nativa en `rc.inet1.conf`);
Solaris y Windows a veces necesitan el arreglo manual (procedimiento documentado en
memoria del proyecto).

### 2.2 Las cuatro máquinas y sus roles

| VM | IP universidad | IP intnet | Rol en el lab |
|---|---|---|---|
| Slackware (`slackware-15.0`) | 10.2.78.74 | 192.168.82.10 | **Maestro** de `camilo.org.uk` + **esclavo** de `juan.com.it` |
| Solaris (`solaris-11.4`) | 10.2.78.75 | 192.168.82.11 | **Maestro** de `juan.com.it` + **esclavo** de `camilo.org.uk` |
| Windows Server GUI | 10.2.78.76 | 192.168.82.13 | **Secundario** de `juan.com.it` (rol DNS de Windows) |
| Windows Server Core | 10.2.78.77 | 192.168.82.12 | **Secundario** de `camilo.org.uk` (rol DNS de Windows) |

Elevación del esquema (por qué es así): cada dominio tiene un primario en un servidor
Linux distinto (para que los DOS dominios tengan redundancia real y no dependan de una
sola máquina) y secundarios en las demás. Slackware es a la vez maestro de uno y
esclavo del otro → es el nodo central. Windows cubre el tercer punto de redundancia.

### 2.3 Acceso a las máquinas

| VM | Usuario | En la uni (SSH directo) | En casa (NAT) | Llave |
|---|---|---|---|---|
| Slackware | vagrant | `vagrant@10.2.78.74` | puerto 2222 | `.ssh/vagrant.key` |
| Solaris | admin | `admin@10.2.78.75` | puerto 2223 | `.ssh/gentle-ai` |
| Windows GUI | Administrator | `Administrator@10.2.78.76` | puerto 2225 | `.ssh/gentle-ai` |
| Windows Core | Administrator | `Administrator@10.2.78.77` | puerto 2224 | `.ssh/gentle-ai` |

> Windows del host: usar `C:\Windows\System32\OpenSSH\ssh.exe` (el de Git for Windows
> falla con "banner exchange: UNKNOWN port -1" contra los forwards NAT).

---

## 3. Parte 1 — DNS: teoría completa

### 3.1 Qué es el DNS

**DNS (Domain Name System)** traduce nombres legibles (`www.google.com`) a direcciones
IP (`142.250.217.132`) y viceversa. Es el servicio que permite que los humanos usen
nombres y las máquinas usen números.

**Característica fundamental:** NO es un diccionario centralizado. Es un sistema
**jerárquico, distribuido y delegado**: cada servidor conoce solo su parte del árbol
de nombres y sabe a quién preguntar por el resto. Esta división de trabajo es lo que
lo hace escalable desde 1983.

**Analogía (arquitectura/edificios):** pedir la dirección de un edificio en un país
desconocido. En el aeropuerto (raíz) te dicen "eso lo maneja la municipalidad" (TLD),
la municipalidad te dice "esa torre la administra tal empresa" (registrador), y la
empresa te da el número exacto. Cada paso "delega" la respuesta al siguiente nivel.

### 3.2 El árbol de nombres

```
.                      ← raíz (root): 13 servidores raíz lógicos (A-M), replicados ~1500 veces
├── com.               ← TLD (Top Level Domain), delegado a Verisign
│   ├── google.com.    ← dominio registrado (delegado por .com a Google)
│   └── juan.com.it.   ← el dominio del lab, que NO existe en el .it real
├── org.
│   └── camilo.org.uk.
├── it.
└── co.
    └── escuelaing.edu.co.
```

**Delegación:** cada nivel del árbol le dice al superior "lo que está bajo mí lo manejo
yo; para lo que está más abajo, preguntá a ESTOS servidores" (registros NS).
Comprar un dominio = lograr que la jerarquía delegue bajo tu control el subárbol
`tudominio.tld`. El lab logra esto DENTRO de su propia infraestructura: el "árbol" del
lab tiene sus propias raíces ficticias (las IPs del intnet) y sus propios delegados.

### 3.3 Roles de los servidores DNS

| Rol | Qué hace | ¿Dónde en el lab? |
|---|---|---|
| **Raíz** | Conoce los TLD; responde con referencias ("preguntale a .com") | Archivo `named.ca` (hints) en cada named |
| **TLD** | Conoce los dominios registrados bajo su TLD | no aplica (el lab no llega a registrarse) |
| **Autoritativo (maestro)** | Es dueño de UNA zona completa, responde de memoria | Slackware (`camilo.org.uk`), Solaris (`juan.com.it`) |
| **Autoritativo (esclavo)** | Tiene la COPIA transferida de una zona ajena, responde igual de autoridad | Slackware, Solaris, Windows GUI, Windows Core |
| **Recursivo / resolver** | Encadena consultas por el árbol hasta encontrar la respuesta | el `named` local de cada VM; el DNS de la escuela |

**Diferencia crítica entre las respuestas:**

- **Autoritativa** (*authoritative answer*): la responde el servidor dueño de la zona
  (maestro o esclavo con la copia). Es la verdad de la zona.
- **No autoritativa** (*non-authoritative answer*): la responde un recursor desde su
  **caché**. NO es falsa — es una copia reciente de la respuesta original.
  El encabezado muestra QUIÉN es el servidor consultado, y eso define el tipo.

### 3.4 Resolución paso a paso (iterativa vs recursiva)

Cuando pedís `nslookup www.google.com 10.2.78.74`:

1. Tu consulta llega al `named` de Slackware (actúa como **recursor**).
2. No tiene la respuesta → consulta a un servidor **raíz** (dirección en `named.ca`).
3. La raíz responde con una **referencia**: "yo no sé, `google.com` lo maneja
   `ns1.google.com` con IP X".
4. El recursor consulta a `ns1.google.com` → respuesta **autoritativa**:
   `www.google.com = 142.250.217.132`.
5. El recursor guarda en **caché** (por el **TTL**) y te devuelve la IP.

Ese encadenamiento es la **resolución iterativa** (cada paso pregunta a UN servidor y
recibe una referencia); TODO el recorrido desde tu punto de vista es **resolución
recursiva** (el recursor hace el trabajo por vos).

### 3.5 Registros DNS (RR — Resource Records)

| Registro | Función | Ejemplo real del lab |
|---|---|---|
| **SOA** | *Start of Authority*: "acta de nacimiento" de la zona: maestro, contacto, serial, timers | `@ IN SOA dns1.juan.com.it. root.juan.com.it. (2026082801 ...)` |
| **NS** | Declara qué servidores son **autoritativos** para la zona | `@ IN NS dns1.juan.com.it.` |
| **A** | nombre → **IPv4** | `srv1.juan.com.it. IN A 10.2.78.74` |
| **AAAA** | nombre → **IPv6** | `dns1.juan.com.it. IN AAAA 2001:db8:1::75` |
| **CNAME** | **Alias**: nombre → OTRO nombre canónico (NUNCA a una IP) | `www.juan.com.it. IN CNAME srv1.juan.com.it.` |
| **MX** | servidor de **correo** + prioridad numérica | (comentado en el lab — no hay correo) |
| **PTR** | IP → nombre (resolución **inversa**) | (opcional en la guía; no se configuró) |
| **TXT** | texto libre (SPF, verificaciones) | — |

**Reglas de oro de los registros:**

- El punto final en `dns1.juan.com.it.` NO es decorativo: marca un FQDN absoluto
  (fully qualified domain name). Sin punto, BIND lo interpreta como relativo a la zona.
- `@` en una zona significa "el dominio de la zona mismo" (ej. `juan.com.it.`).
- CNAME: al consultar un alias, la respuesta trae el CNAME Y el A del destino en el
  mismo mensaje. Un CNAME no puede coexistir con otros registros para el mismo nombre.
- MX usa prioridades (números bajos = mayor prioridad): `10 mail1`, `20 mail2`.

### 3.6 SOA y temporizadores (la replicación en detalle)

```
@ IN SOA dns1.camilo.org.uk. root.camilo.org.uk. (
    2026082801 ; Serial (yyyyMMdd + consecutivo del día)
    10800      ; Refresh 3h   — cada cuánto el esclavo revisa el serial del maestro
    3600       ; Retry 1h     — si el maestro no responde, reintentar a la hora
    604800     ; Expire 1sem  — si no responde por 1 semana, dejar de servir la zona
    86400 )    ; Negative TTL 1d — caché de respuestas negativas (NXDOMAIN/No answer)
```

**Serial:** es EL mecanismo de sincronización. Cada cambio en la zona debe SUBIRLO
(`2026082802`, `2026082803`...). Si no sube el serial, los esclavos NO transfieren.
Formato recomendado por la guía: `yyyyMMddxx` (fecha + consecutivo del día).

**Ciclo de replicación maestro → esclavo:**

1. El esclavo consulta el serial del maestro cada **Refresh**.
2. Si el serial del maestro es MAYOR → pide la zona: **AXFR** (transferencia total)
   o **IXFR** (incremental, si el maestro lo soporta).
3. Si el maestro no responde, reintenta cada **Retry**.
4. Si pasa el **Expire** sin respuesta, el esclavo deja de responder por la zona
   (la copia se considera caduca).
5. `notify yes` en el maestro: aviso PROACTIVO "¡cambié!, vengan a buscar".

**Verificación en el lab:** serial `2026082801` coincidente en los 4 servidores =
replicación al día.

### 3.7 Caché y TTL

- **TTL** (Time To Live): cuántos segundos los recursores pueden guardar una respuesta
  antes de re-consultar. En las zonas del lab `$TTL 86400` (1 día).
- La caché es lo que hace al DNS rápido y resistente, pero también retrasa la
  propagación de cambios (por eso bajar el TTL ANTES de un cambio grande es una
  práctica conocida).
- Los valores del SOA (refresh/retry/expire) gobiernan la replicación entre
  servidores; el TTL gobierna la caché de los recursores.

### 3.8 Puertos y transporte

- **UDP 53**: consultas normales (mensajes pequeños).
- **TCP 53**: transferencias de zona (AXFR/IXFR) y consultas grandes
  (DNSSEC, respuestas > 512 bytes) que requieren retransmisión confiable.
- Para diagnosticar: `ss -lunp | grep :53` (escucha UDP 53) y `ss -ltnp | grep :53`
  (escucha TCP 53) — o `netstat` equivalente.

### 3.9 Los 6 resultados posibles de nslookup

| Resultado | Significado |
|---|---|
| `Name:` + `Address:` | Consulta normal: se resolvió el registro A |
| `nameserver = dns1.juan.com.it.` | Respuesta a una consulta tipo NS |
| `Non-authoritative answer` | La respondió un recursor con caché (no el autoritativo) |
| `Authoritative answer` | La respondió el servidor dueño de la zona |
| `Can't find ... No answer` | Consulta válida pero ese TIPO de registro no existe (ej. MX) — NO es error |
| `NXDOMAIN` | El nombre NO EXISTE en el árbol que el servidor conoce |

---

## 4. Parte 1 — DNS: los archivos de configuración explicados línea por línea

Todo lo siguiente fue **leído en vivo desde las máquinas** (02/09/2026) y coincide con
lo transcrito al informe.

### 4.1 Slackware: `/etc/named.conf` (maestro de `camilo.org.uk`)

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
	masters { 192.168.82.11; 10.2.78.75; };
	file "juan.com.it.slave";
};
```

**Línea por línea (qué significa cada cosa y POR QUÉ está):**

| Línea | Significado técnico | Por qué está así en el lab |
|---|---|---|
| `options { directory "/etc/DNS"; }` | Todo nombre de archivo de zona se resuelve relativo a `/etc/DNS` | La guía de Slackware lo pide así; ahí viven `camilo.org.uk.hosts`, `named.ca`, `named.soa` |
| `dnssec-validation no;` | Desactiva la validación de firmas DNSSEC de cadena de confianza | En redes internas sin cadena válida evita `SERVFAIL` al resolver externos desde el caché local |
| `zone "." IN { type hint; file "named.ca"; }` | Define la zona **raíz** como "hints": solo direcciones iniciales de los servidores raíz | Es lo que permite resolver dominios EXTERNOS (`www.google.com`) |
| `zone "0.0.127.in-addr.arpa"` | Zona reversa de loopback: `127.0.0.1` → `localhost` | Estándar de BIND (fábrica); evita warnings al arrancar |
| `type master` + `allow-update { none; }` | La zona es maestra y NO se aceptan actualizaciones dinámicas | Seguridad: nadie puede inyectar registros desde la red |
| `zone "camilo.org.uk" IN { type master; }` | Declara que Slackware es **maestro** (autoritativo primario) de esta zona | Es el primario del dominio del grupo |
| `file "camilo.org.uk.hosts"` | Archivo de datos de la zona | Contenido en 4.2 |
| `allow-transfer { 192.168.82.11; 192.168.82.12; }` | SOLO estos IPs pueden pedir transferencias de zona (AXFR) | Solaris (esclavo Linux) y Windows Core (esclavo Windows). Nada más: así nadie externo roba la zona |
| `notify yes;` | El maestro avisa a los esclavos cuando la zona cambia | Replicación rápida sin esperar el Refresh |
| `zone "juan.com.it" IN { type slave; }` | Slackware es **esclavo** del dominio del otro integrante | Redundancia cruzada: si Solaris cae, Slackware sigue resolviendo juan.com.it |
| `masters { 192.168.82.11; 10.2.78.75; }` | De QUIÉN tomar la zona: Solaris por su IP del intnet y por su IP uni | Doble camino de transferencia (el intnet es el principal; la uni es respaldo) |
| `file "juan.com.it.slave"` | Dónde el esclavo guarda la COPIA transferida | BIND la escribe al transferir; NO se edita a mano |

### 4.2 Slackware: `/etc/DNS/camilo.org.uk.hosts` (zona maestra)

```
;
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

**Línea por línea:**

| Línea | Significado |
|---|---|
| `; ...` | Comentarios (igual que `#` en otros formatos) |
| `$TTL 86400` | TTL por defecto de TODOS los registros sin TTL propio: 24 horas |
| `$INCLUDE named.soa` | Inserta el contenido de `named.soa` (el SOA) — evita duplicar el bloque en cada zona |
| `@ IN NS dns1.camilo.org.uk.` | `@` = la zona misma. "El dominio camilo.org.uk es servido (autoritativamente) por dns1.camilo.org.uk" |
| `localhost.camilo.org.uk. IN A 127.0.0.1` | Nombre local de la zona apuntando a loopback (requisito de la guía) |
| `dns1 IN A 10.2.78.74` | SERV1: el servidor DNS de la zona es Slackware (.74) |
| `srv1 IN A 10.2.78.75` | SERV2 de la guía: Solaris (servidor 1 de la empresa) |
| `srv2 IN A 10.2.78.76` | SERV3: Windows GUI (servidor 2 de la empresa) |
| `dns1 IN AAAA 2001:db8:2::74` | IPv6 del DNS (rango de documentación `2001:db8::/32`, subred 2 para camilo) |
| `srv2 IN AAAA 2001:db8:2::76` | IPv6 del segundo servidor |
| `www IN CNAME srv1` | Alias web → Solaris (IPv4) |
| `mail IN CNAME dns1` | Alias correo → Slackware (IPv4) — aunque no haya MX, el nombre queda listo |
| `v6 IN CNAME srv2` | Alias hacia el servidor con IPv6 (obliga a que la cadena resuelva AAAA) |

**Cumplimiento de la guía 1.1:** 3 A ✅ · 2 AAAA ✅ · 2 CNAME a IPv4 (`www`, `mail`) ✅ ·
1 CNAME a IPv6 (`v6`) ✅ · NS ✅ · MX comentado/no presente ✅

### 4.3 Slackware: `/etc/DNS/named.soa`

```
; named.soa - SOA de la zona (incluido por $INCLUDE)
;
@ IN SOA dns1.camilo.org.uk. root.camilo.org.uk. (
	2026082801 ; Serial yyyymmddxx
	10800      ; Refresh 3h
	3600       ; Retry 1h
	604800     ; Expire 1sem
	86400 )    ; Negative TTL 1d
```

| Campo | Valor | Significado |
|---|---|---|
| `@ IN SOA` | — | El SOA describe la zona misma |
| `dns1.camilo.org.uk.` | **MNAME** | Servidor primario de la zona |
| `root.camilo.org.uk.` | **RNAME** | Contacto administrativo (el `@` se escribe como punto: `root@camilo.org.uk`) |
| `2026082801` | **Serial** | 28/08/2026, consecutivo 01 — subir en cada cambio |
| `10800` | **Refresh** | 3 horas |
| `3600` | **Retry** | 1 hora |
| `604800` | **Expire** | 1 semana |
| `86400` | **Negative TTL** | 1 día |

### 4.4 Slackware: `/etc/DNS/named.ca` (hints de raíz)

```
; named.ca - Root name servers (hints)
.			3600000	IN	NS	A.ROOT-SERVERS.NET.
A.ROOT-SERVERS.NET.	3600000	IN	A	198.41.0.4
A.ROOT-SERVERS.NET.	3600000	IN	AAAA	2001:503:BA3E::2:30
B.ROOT-SERVERS.NET.	3600000	IN	A	170.247.170.2
C.ROOT-SERVERS.NET.	3600000	IN	A	192.33.4.12
```

| Línea | Significado |
|---|---|
| `. 3600000 IN NS A.ROOT-SERVERS.NET.` | "La zona raíz es servida por A.ROOT-SERVERS.NET" (TTL 1000 h) |
| `A.ROOT-SERVERS.NET. IN A 198.41.0.4` | Dirección IPv4 del root server A |
| `A.ROOT-SERVERS.NET. IN AAAA 2001:503:BA3E::2:30` | Dirección IPv6 del root server A (¡la guía pide A y AAAA!) |
| `B.ROOT-SERVERS.NET. IN A 170.247.170.2` | Root server B |
| `C.ROOT-SERVERS.NET. IN A 192.33.4.12` | Root server C |

**Por qué la guía pide "empezar con uno, probar, y agregar al menos dos más":**
demostrar que con UNA raíz alcanza (resolución iterativa) pero con varias hay
redundancia si una falla. El lab quedó con A, B y C, y AAAA en A.

### 4.5 Slackware: activación al arranque

- `/etc/rc.d/rc.bind`: presente, **ejecutable** (`-rwxr-xr-x`), es el script de
  arranque del servidor de nombres en Slackware (rc.* son scripts de init de Slack).
- Proceso en vivo verificado: `518 /usr/sbin/named -u named` (corre como usuario
  `named`, no como root — buena práctica de seguridad).

### 4.6 Solaris: `/etc/named.conf` (maestro de `juan.com.it`)

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

Diferencias contra Slackware (todo lo demás es idéntico en concepto):

| Diferencia | Por qué |
|---|---|
| `directory "/etc/inet/DNS"` | En Solaris los archivos de zona viven en `/etc/inet/DNS` (convención del SO) |
| `juan.com.it` es `type master` | El dominio de JD es primario en Solaris |
| `allow-transfer { 192.168.82.10; 192.168.82.13; }` | Solo Slackware (esclavo Linux) y Windows GUI (esclavo Windows) |
| `camilo.org.uk` es `type slave` con `masters { 192.168.82.10; }` | Solaris toma el dominio de CA desde Slackware |
| `masters` tiene SOLO intnet | En Solaris no se agregó la IP uni como respaldo (funciona igual; el intnet es la vía natural) |

> Lección de portabilidad aprendida en el lab: Solaris trae herramientas viejas
> (grep sin `-E`, cron sin `crontab -`, IP otra sintaxis de red: `ipadm`, no `ip`).
> Los archivos de zona NO difieren en sintaxis: el formato de zonas BIND es portable.

### 4.7 Solaris: `/etc/inet/DNS/juan.com.it.hosts`

```
;
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

**Espejo exacto de la zona de CA pero con los nombres del dominio de JD:**
`dns1` = Solaris (.75), `srv1` = Slackware (.74), `srv2` = Windows GUI (.76);
IPv6 en `2001:db8:1::` (subred 1 para juan); aliases `www`, `mail`, `v6` iguales.
(los dos dominios registran los mismos servidores físicos pero bajo sus propios
nombres: es el "espacio de nombres de cada empresa").

### 4.8 Solaris: SOA, named.ca y SMF

- `named.soa`: idéntico concepto — `@ IN SOA dns1.juan.com.it. root.juan.com.it.
  (2026082801 10800 3600 604800 86400)`. Mismo serial que camilo → se actualizaron
  juntos el 28/08.
- `named.ca`: mismo contenido de root servers (A, B, C con AAAA en A).
- **Arranque/activación (SMF — Service Management Facility):**

```
fmri         svc:/network/dns/server:default
name         BIND DNS server
enabled      true
state        online
logfile      /var/svc/log/network-dns-server:default.log
manifest     /lib/svc/manifest/network/dns/server.xml
```

`enabled=true` + `state=online` = el servicio arranca solo y está activo (punto 9 ✅).
Comandos útiles Solaris: `svcs dns/server`, `svcadm disable/enable dns/server`,
`svccfg` para ver el manifest.

---

## 5. Parte 1 — DNS: configuración de los secundarios Windows

### 5.1 Instalación del rol

```powershell
Install-WindowsFeature DNS   # GUI y Core, 29/08/2026, sin reinicio requerido
```

### 5.2 Zonas secundarias

| VM | Zona secundaria | Maestro (IP intnet) | Verificado |
|---|---|---|---|
| Windows Server GUI | `juan.com.it` | Solaris 192.168.82.11 | `ZoneType Secondary`, `MasterServers 192.168.82.11`, servicio `DNS Running/Automatic` |
| Windows Server Core | `camilo.org.uk` | Slackware 192.168.82.10 | `ZoneType Secondary`, `MasterServers 192.168.82.10`, servicio `DNS Running/Automatic` |

Comandos de referencia:

```powershell
Add-DnsServerSecondaryZone -Name "juan.com.it" -ZoneFile "juan.com.it.dns" `
  -MasterServers 192.168.82.11
Add-DnsServerSecondaryZone -Name "camilo.org.uk" -ZoneFile "camilo.org.uk.dns" `
  -MasterServers 192.168.82.10
Get-DnsServerZone -Name "juan.com.it"    # ZoneType: Secondary
Get-Service DNS                          # Running / Automatic
```

**Importante:** para que Windows transfiera, el MAESTRO BIND debe permitir la IP de
Windows en `allow-transfer` — por eso en Slackware están 192.168.82.12 (Core) y en
Solaris 192.168.82.13 (GUI). Si la transferencia falla, revisar: (1) allow-transfer
del maestro, (2) conectividad intnet, (3) que el servicio DNS de Windows esté
Running, (4) eventos en el visor de DNS.

---

## 6. Parte 1 — DNS: pruebas realizadas y comportamiento esperado

### 6.1 Batería verificada en vivo (02/09/2026, desde Slackware)

```bash
nslookup srv1.juan.com.it 10.2.78.74       # → 10.2.78.74 (esclavo responde)
nslookup -type=NS juan.com.it 10.2.78.74   # → dns1.juan.com.it
nslookup -type=A  srv2.juan.com.it 10.2.78.74  # → 10.2.78.76 (Windows)
nslookup -type=MX juan.com.it 10.2.78.74   # → No answer (esperado: no hay MX)
nslookup srv1.juan.com.it 10.2.65.1        # → NXDOMAIN (DNS de la escuela)
nslookup www.google.com 10.2.65.1          # → resuelve (recursor externo)
```

### 6.2 Esclavos cruzados

```bash
# En Slackware (esclavo de juan.com.it): srv1.juan.com.it → 10.2.78.74
# En Solaris   (esclavo de camilo.org.uk): srv1.camilo.org.uk → 10.2.78.75
# Serial 2026082801 en ambos = replicación OK
```

### 6.3 Prueba en el propio servidor (punto 8) — por qué funciona

`nslookup camilo.org.uk 127.0.0.1` (en Slackware) responde porque:

1. BIND escucha en **loopback** (`127.0.0.1`) además de las IPs físicas.
2. El servidor es **autoritativo** para su zona: responde de memoria, sin consultar
   a nadie (la respuesta sale marcada como autoritativa).
3. Las zonas esclavas responden igual: el esclavo guardó la transferencia y sirve ESA
   copia como autoritativo local (basta que el serial coincida con el maestro).

IP final documentada: Slackware 192.168.82.10 / Solaris 192.168.82.11 (intnet).

### 6.4 Comportamiento "extraño" esperado (para no asustarse en el video)

| Consulta | Resultado | Por qué es normal |
|---|---|---|
| `nslookup juan.com.it 10.2.78.74` (dominio a secas) | `No answer` | No hay registro A para el dominio desnudo, solo para srv1/www |
| `nslookup -type=MX juan.com.it 10.2.78.74` | `No answer` | La zona no tiene MX (guía: MX comentado) |
| `nslookup srv1.juan.com.it 10.2.65.1` | `NXDOMAIN` | El mundo no conoce juan.com.it (no está delegado en .it real) |
| En las respuestas desde Slackware | aparece caveat de servidor | Según cómo se lance, puede salir "non-authoritative" si el named responde desde caché de otra consulta previa |

---

## 7. Parte 2 — Programación Shell: teoría y scripts

### 7.1 Teoría mínima

**cron** — servicio de tareas periódicas. Tabla con 5 campos de tiempo + comando:

```
minuto hora día-mes mes día-semana comando
*/1 * * * * /ruta/script.sh     # cada minuto (en Linux)
* * * * * /ruta/script.sh       # igual, en Solaris (¡no soporta */N!)
```

**ps** — listar procesos: `ps -eo pid,comm,%mem,%cpu` (Linux) / `ps -efo pid,comm,pmem,pcpu` (Solaris).

**kill** — enviar señales: `kill <pid>` (TERM), `kill -9 <pid>` (KILL, inofensivo para
procesos sin datos), `kill -CONT <pid>` (continuar).

**find/du/sort/head** — recorrer archivos: `find dir -type f -size +1M`,
`du -b`, `sort -n`, `head -n N`.

### 7.2 Los tres scripts (estado)

| Script | Función | Ejemplo | Estado |
|---|---|---|---|
| `schedult-task-script.sh` | Programar tarea periódica por línea de comandos (cron) | `./schedult-task-script.sh * * * * *` | ✅ probado en Slackware y Solaris (corregido portabilidad) |
| `menu-procesos.sh` | Menú: listar/buscar/matar/reiniciar procesos, salir | — | ✅ probado en Slackware y Solaris (corregido portabilidad) |
| `files-script.sh` | Recorrer filesystem y listar los N archivos más pequeños bajo un tamaño máx | `./files-script.sh 10 1GB` | 🔲 copiar y probar en Solaris |

**Portabilidad Solaris (lecciones ya pagadas en el lab):**

1. `crontab -` (leer por stdin) NO existe en Solaris → usar archivo temporal:
   `crontab /tmp/crontab.$$~`.
2. La sintaxis `*/N` NO es válida en el cron de Solaris → expandir el rango
   (`0-59/1`) o generar la tabla con el mismo script.
3. `grep -E` NO existe en Solaris (grep viejo) → usar `egrep` o patrones básicos.
4. `tail -f`, `ps` flags y rutas difieren; probar SIEMPRE en ambas máquinas.

### 7.3 Qué demostrar al instructor

- Tarea programada visible con `crontab -l`.
- Menú: listar → buscar → matar → reiniciar → salir, con capturas.
- Recorrido: `./files-script.sh 10 1GB` mostrando nombre/ruta/tamaño de los 10
  archivos más pequeños ≤ 1GB.

---

## 8. Parte 3 — Amazon EC2: teoría

### 8.1 Conceptos

| Componente | Qué es |
|---|---|
| **AMI** | *Amazon Machine Image*: plantilla SO + arranque + apps (Amazon Linux, Ubuntu, Windows...) |
| **Instance type** | Tamaño: vCPUs, memoria, red (t2.micro/t3.micro = Free Tier) |
| **Key pair** | Par SSH: privada (`.pem`) en tu PC, pública inyectada en la instancia |
| **VPC / subnet** | Red virtual de AWS (default = red por defecto) |
| **Security group** | Firewall virtual por instancia (para el lab: SSH 22 desde 0.0.0.0/0) |
| **EBS** | Almacenamiento en bloque **persistente** desacoplado de la instancia |
| **Ephemeral (instance store)** | Disco **temporal** ligado al host físico: se pierde al detener/terminar |
| **Precio** | Pay-as-you-go + Free Tier (750 h/mes de t2.micro en el tier clásico) |

### 8.2 Pasos de lanzamiento

1. Consola EC2 → elegir **Región**.
2. *Launch instance* → nombre descriptivo.
3. **AMI**: Quick Start → Amazon Linux (Free Tier eligible).
4. **Instance type**: Free Tier eligible.
5. **Key pair**: crear nueva o usar existente.
6. **Network**: VPC/subnet default; security group con SSH (22).
7. **Storage**: volumen raíz por defecto.
8. Revisar → *Launch instance*.
9. Estado: `pending → running`; esperar **status checks 2/2**.
10. **Connect** → pestaña *SSH client* → copiar comando:

```bash
ssh -i key-pair-name.pem ec2-user@ec2-XXX.us-east-2.compute.amazonaws.com
```

11. Verificar fingerprint (*Get system log* si hace falta) → `yes` → listo.

### 8.3 Estado real del lab

- Instancia previa `44.204.11.182`: **no responde** (puerto 22 y ping timeout) desde
  el incidente del apagón — probablemente terminada o en estado raro.
- `aws` CLI **no instalado** en el Windows del host (usar consola web o instalarlo).
- Key pair: `lab03-key.pem` (raíz del repo).
- Todo lo demás pendiente (ver sección 9.3).

---

## 9. Preguntas de la guía con respuesta desarrollada

### 9.1 Parte DNS (4-10)

**4. ¿Qué son los registros A y AAAA en el archivo de servidores raíz?**
Son las direcciones de los servidores raíz del DNS: IPv4 (A) e IPv6 (AAAA). El
resolver los usa como **punto de entrada** para la resolución iterativa de dominios
externos: consulta una raíz y recibe la referencia al TLD correspondiente. La guía
pide empezar con una raíz, probar, y agregar al menos dos más — en el lab: A.ROOT
(198.41.0.4 + AAAA), B.ROOT (170.247.170.2), C.ROOT (192.33.4.12).

**5. ¿Qué son los registros NS, MX, A y CNAME en el archivo del dominio particular?**
- **NS**: declara los servidores autoritativos de la zona (en el lab: `dns1`).
- **MX**: declara el servidor de correo con prioridad (no usado en el lab, por eso
  da "No answer").
- **A**: nombre canónico → IPv4.
- **CNAME**: alias → otro nombre canónico (nunca IP); la respuesta incluye el A del
  destino en el mismo mensaje.

**6. Revisar logs:** `/var/svc/log/network-dns-server:default.log` (Solaris) y
`/var/log/messages` (Slackware) sin errores de carga de zona (verificado 01/09/2026).

**7. Video nslookup (A-G):** guion en `GUION-VIDEO-NSLOOKUP-LAB03.md`, salidas reales
en `evidencias/video-nslookup-*.txt` y `foto-7c-escuela.png`. Resultados esperados:
A: qué es nslookup · B: `srv1.juan.com.it` → 10.2.78.74 · C: contra 10.2.65.1 →
NXDOMAIN (y google resuelve) · D: NS → dns1.juan.com.it · E: -debug → QUESTIONS
(A+AAAA) y ANSWERS + SOA · F: -type=A → srv2 = 10.2.78.76 · G: -type=MX → No answer.
🔲 Falta grabar/editar.

**8. Prueba en el propio servidor:** funciona porque BIND escucha en 127.0.0.1 y el
servidor es autoritativo (responde sin consultar). Esclavas también: copia transferida
con serial igual. Evidencias: `server-propio-slackware.txt`, `server-propio-solaris.txt`.
IP final: 192.168.82.10 (Slackware), 192.168.82.11 (Solaris).

**9. Activación al arranque:** Slackware `rc.bind` ejecutable + `named -u named`
activo; Solaris SMF `enabled=true` + `state=online`; Windows `DNS Running/Automatic`.
Evidencia: `servicio-boot.txt`.

**10. Mostrar al instructor:** 🔲 pendiente de sustentación.

### 9.2 Parte EC2 (next steps — respuestas base para redactar)

1. **STOP vs TERMINATE vs RESTART:** *Stop* apaga el SO; los volúmenes EBS persisten;
   se deja de facturar cómputo y se puede volver a arrancar. *Terminate* ELIMINA la
   instancia definitivamente (el volumen raíz se borra por defecto, salvo protección).
   *Restart* reinicia el SO en la misma instancia (tras cambios de kernel/config).
2. **Rol de la AMI:** define el SO, esquema de arranque, software precargado y
   permisos. Es la "foto" desde la que se clona la instancia.
3. **Cuándo elegir otra AMI:** otro SO/distribución, software preinstalado, kernel
   especial, licenciamiento o seguridad (AMI endurecidas). Amazon Linux cubre el lab.
4. **EBS vs ephemeral:** EBS = persistente, desacoplado, con snapshots, sobrevive a
   stop/terminate (si no se elimina). Ephemeral = temporal, ligado al host, se pierde.
5. **Ejecutar comandos remotos SIN SSH:** AWS Systems Manager Run Command / Session
   Manager (requiere agente SSM + IAM role; no abre el puerto 22).
6. **Adjuntar EBS a Linux:** crear volumen (misma AZ) → `attach-volume` (consola o
   `aws ec2 attach-volume ...`) → `lsblk` → `mkfs.ext4 /dev/xvdf` → `mount` →
   `/etc/fstab` para persistencia.
7. **Datos EBS al detener/terminar:** stop → se conservan; terminate → el raíz se
   elimina (salvo protección), los adicionales se conservan; ephemeral siempre se pierde.
8. **¿El Shell de Slackware corre en la instancia?** En general sí (ambos Linux,
   bash/sh, coreutils, cron). Diferencias: Slackware usa pkgtools, Amazon Linux
   `yum/dnf`; rutas y herramientas específicas pueden faltar; el script debe ser
   POSIX-portable. 🔲 probar en la instancia.

---

## 10. Entregables, estado de avance y plan

| # | Entregable | Estado |
|---|---|---|
| 1 | Configuración DNS en 3+ servidores, resolución interna y externa | ✅ Verificado |
| 2 | Respuestas preguntas DNS (4-10) | 🟡 4,5,6,8,9 hechas · falta 7 (video) y 10 |
| 3 | Video nslookup ≤ 5 min (A-G) | 🔲 Pendiente (guion y evidencias listos) |
| 4 | Tres scripts Shell en Solaris y Slackware | 🟡 Probados en Slackware · falta Solaris + transcribir |
| 5 | EC2: preguntas + instancia probada por SSH | 🔲 Pendiente |
| 6 | Informe con evidencia | 🟡 Avanzado · faltan apéndices A/B, conclusiones, bibliografía |

**Plan de trabajo recomendado (por prioridad):**
1. Grabar el video nslookup (máquinas arriba, DNS verificado en vivo).
2. Copiar y probar los 3 scripts en Solaris; capturar pantallas.
3. EC2: verificar/re-lanzar instancia + responder preguntas + probar Shell.
4. Completar informe: apéndices A/B, conclusiones, bibliografía.
5. Definir con el profesor: rango IPv4/IPv6 oficial, cuenta AWS Free Tier, fecha de
   sustentación.

---

## 11. Evidencias y archivos del repo

| Archivo | Contenido |
|---|---|
| `RESUMEN-LAB03.txt` | Resumen del enunciado de la guía (28/08) |
| `informe-laboratorio-03.md` | Informe formal del lab (en progreso) |
| `GUION-VIDEO-NSLOOKUP-LAB03.md` | Guion del video nslookup (A-G, mitades CA/JD) |
| `GUIA-EDICION-VIDEOS-LAB03.md` | Guía de edición de videos |
| `evidencias/video-nslookup-BDE.txt`, `video-nslookup-FGC.txt` | Salidas reales para el video (29/08) |
| `evidencias/foto-7c-escuela.png` | Bloque C: NXDOMAIN contra DNS de la escuela |
| `evidencias/server-propio-slackware.txt`, `server-propio-solaris.txt` | Punto 8 |
| `evidencias/servicio-boot.txt` | Punto 9 |
| `scripts/schedult-task-script.sh`, `menu-procesos.sh`, `files-script.sh` | Scripts Parte 2 |
| `lab03-key.pem` | Key pair EC2 (raíz del repo) |

---

## 12. Glosario rápido

| Término | Definición corta |
|---|---|
| A | registro: nombre → IPv4 |
| AAAA | registro: nombre → IPv6 |
| AXFR | transferencia completa de zona |
| BIND | el servidor DNS más usado (named) |
| CNAME | alias → nombre canónico |
| FQDN | nombre absoluto con punto final |
| IXFR | transferencia incremental |
| MX | servidor de correo + prioridad |
| NS | servidor autoritativo de la zona |
| NXDOMAIN | el nombre no existe |
| resolver | software que encadena consultas (recursor) |
| SOA | acta de la zona (maestro, serial, timers) |
| TLD | dominio de nivel superior (.com, .org...) |
| TTL | tiempo de vida de una respuesta en caché |
| zona | porción del árbol que un servidor administra |