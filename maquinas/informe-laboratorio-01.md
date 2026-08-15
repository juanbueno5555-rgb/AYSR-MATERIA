# Laboratorio No. 01 — Base Platform

**Curso:** [nombre del curso]
**Grupo:** 2 estudiantes — [Nombre 1], [Nombre 2]
**Fecha:** [fecha de entrega]
**Instructor:** [nombre]

> Estructura del documento según la metodología: Introducción · Desarrollo del tema · Marco teórico · Uso y aplicaciones · Conclusiones · Bibliografía.
> Los ítems entre corchetes `[PENDIENTE: ...]` se completan a medida que avanzamos.
> Las evidencias (capturas) están en `lab-evidencias/`.

---

## 1. Introducción

Dado que el objetivo es instalar y configurar distintas maquinas mediante virtualizacion, a continuacion explicamos como podemos lograr esto, mediante software de virtualizacion como vitual box o vmware.

- Contexto: una empresa opera servicios de TI (estaciones de trabajo cableadas e inalámbricas, servidores físicos y virtualizados, switches L2/L3, routers y nube).
- Alcance: instalación de Slackware, Solaris, Windows Server (2 fases), Android y CentOS (solo grupos de 3; este grupo es de 2, no aplica).
- Herramientas: VMware, máquinas del laboratorio, ISO descargadas.

---

## 2. Marco teórico

### 2.1 Virtualización

**¿Qué es un hipervisor?**

Un hipervisor (o monitor de máquina virtual, VMM) es una capa de software que crea y administra máquinas virtuales sobre un mismo hardware físico. Actúa como intermediario entre el hardware y los sistemas operativos invitados: asigna recursos (CPU, memoria, almacenamiento y red), atiende las instrucciones privilegiadas de cada invitado y garantiza el aislamiento entre máquinas: una VM no puede acceder a la memoria ni a los datos de otra, simulando una maquina totalmente distinta desde el mismo ordenador.

**Clasificación**

- **Hipervisor Tipo 1 (bare-metal):** se instala directamente sobre el hardware físico, sin sistema operativo anfitrión. Ejemplos: VMware ESXi, Microsoft Hyper-V, Xen y KVM. Es el modelo de los centros de datos y de la nube.
- **Hipervisor Tipo 2 (hosted):** se ejecuta como una aplicación sobre un sistema operativo anfitrión. Ejemplos: Oracle VirtualBox y VMware Workstation. Es el modelo usado en este laboratorio para probar varias distribuciones sobre el mismo equipo.

**Características**

- Aislamiento: cada VM es independiente; un fallo en una no afecta a las demás.
- Partición de recursos: el hipervisor divide CPU, memoria y disco entre las VM.
- Encapsulación: la VM completa se representa como archivos (`.vmx`, `.vmdk`), portables y copiables.
- Independencia del hardware: la VM puede migrar entre anfitriones compatibles.
- Instantáneas (snapshots) y, en Tipo 1, migración en vivo sin interrupción del servicio.

**Arquitectura**

Cada VM ejecuta un sistema operativo invitado que cree estar sobre hardware real: CPU virtual (apoyada en las extensiones de virtualización VT-x/AMD-V), memoria virtual, disco virtual y tarjeta de red virtual. El hipervisor intercepta las instrucciones privilegiadas del invitado y las ejecuta en modo supervisor, o las emula mediante dispositivos virtuales; en un Tipo 2, un proceso del anfitrión atiende además las operaciones de entrada/salida (disco y red).

**Cloud computing**

El cómputo en la nube entrega servicios de procesamiento, almacenamiento, redes, bases de datos y software a través de internet, bajo demanda y con pago por uso. Se distinguen tres modelos de servicio: IaaS (infraestructura como servicio: máquinas virtuales, redes y almacenamiento), PaaS (plataforma para desplegar aplicaciones) y SaaS (software completo). El despliegue puede ser público, privado o híbrido.

**¿Se usan hipervisores en la nube? Sí.**

La infraestructura de los proveedores de nube pública (AWS, Azure, Google Cloud) está construida sobre hipervisores (KVM, Xen, Hyper-V): el modelo IaaS expone directamente máquinas virtuales; la multitenencia (varios clientes sobre el mismo hardware físico) y la elasticidad (crear o liberar máquinas en segundos) son posibles gracias a la virtualización.

**Comparación de costos: servidor físico vs. servidor en la nube**

- Servidor físico: alta inversión inicial (CAPEX) en hardware, más costos fijos de energía, enfriamiento, espacio, mantenimiento y personal; suele quedar sobredimensionado para cubrir los picos de carga.
- Servidor en la nube: gasto operativo (OPEX) bajo demanda, sin mantenimiento de hardware y con elasticidad real, pero con costo continuo: en usos 24/7 constantes a largo plazo puede superar el costo del hardware propio.
- Conclusión: la nube conviene cuando la carga es variable o el proyecto es nuevo; el hardware propio conviene con carga constante y alta utilización, o cuando se requiere control total sobre el equipo.

**Contenedores**

Un contenedor es una forma de virtualización a nivel del sistema operativo: varios contenedores comparten el kernel del anfitrión, pero sus procesos, sistema de archivos y red están aislados mediante namespaces y cgroups. El contenedor empaqueta la aplicación con todas sus dependencias en una imagen portable y liviana. Ejemplos: Docker, Podman y containerd; la orquestación se hace con Kubernetes.

**Similitudes y diferencias entre máquinas virtuales y contenedores**

| Aspecto | Máquinas virtuales | Contenedores |
|---|---|---|
| Qué virtualizan | el hardware | el sistema operativo |
| Kernel | uno por VM (invitado) | compartido con el anfitrión |
| Aislamiento | completo y fuerte | a nivel de procesos |
| Tamaño y arranque | gigabytes, minutos | megabytes, segundos |
| Densidad por servidor | decenas | cientos o miles |
| Caso de uso | consolidación, SO heterogéneos | microservicios, CI/CD |

**Similitudes:** ambos aíslan aplicaciones y recursos, encapsulan la aplicación con su entorno y permiten densidades de despliegue mucho mayores que las físicas. En la práctica se complementan: los contenedores corren sobre las máquinas virtuales en lugar de competir con ellas.

### 2.2 Sistemas operativos

- **Sistema de archivos:** estructura con la que el sistema organiza y almacena los datos en disco: jerarquía de directorios desde la raíz `/`, archivos con metadatos (permisos, fechas, propietario). En el laboratorio se usaron ext4 (Slackware, con journaling), ZFS (Solaris, con pools, instantáneas y sumas de verificación) y NTFS (Windows).
- **Permisos:** control de acceso a archivos y directorios: tripleta r/w/x para propietario, grupo y otros, con equivalente octal (4/2/1); en Windows se usan ACL (NTFS). Ver sección 3.3.3.
- **Logs:** archivos donde el sistema y los servicios registran eventos: syslog en Unix, Visor de eventos en Windows. Ver sección 3.3.2.
- **Shell:** intérprete de comandos que ejecuta programas y da acceso a los servicios del sistema: interactivo y de scripting en Unix; `cmd` y PowerShell en Windows. Ver sección 3.7.

---

## 3. Desarrollo del tema

### 3.1 Software de virtualización (preguntas del punto 1 del lab)
- ¿Qué son los hipervisores?
- ¿Cómo se clasifican?
- ¿Cuáles son sus características?
- Explicar su arquitectura.
- ¿Qué es cloud computing?
- ¿Se usan hipervisores en cloud computing? Justificar.
- ¿Cuál es la diferencia de costo entre un servidor físico y uno en la nube?
- ¿Qué son los contenedores? Explicar su arquitectura.
- Similitudes y diferencias entre máquinas virtuales y contenedores.

> Nota: este tema se presenta en este video. Link ...

### 3.2 Configuración de servidores Unix: Slackware y Solaris

#### 3.2.1 Instalación y configuración (VMware, modo experto, sin entorno gráfico)

**Slackware 15.0** (instalación en modo consola, sin entorno gráfico), proceso paso a paso, evidencias en `lab-evidencias/`:

- `05-instalando-series.png`, `06-instalando-series2.png`, `07-instalando-series3.png` — instalación de las series de paquetes.
- `09-boot-con-pae.png` — arranque del sistema con soporte PAE habilitado.
- `09-primer-boot.png` — primer arranque del sistema instalado.
- `10-login-hd.png`, `11-login-1024.png`, `12-login-root.png` — pantallas de login (HD, resolución 1024 y login como root).
- `13-sistema.png` — sistema operativo funcionando en consola.
- `14-red-dhcp.png` — configuración de red inicial por DHCP.
- `15-ping-tests.png` — pruebas de conectividad (ping).
- `16-directorios.png` — estructura de directorios del sistema.
- `17-teclado-es.png` — selección de teclado en español.

**Solaris 11.4** (Text Installer, en modo texto), proceso paso a paso, evidencias en `lab-evidencias/`:

- `solaris-02-language.png` — selección del idioma (español).
- `solaris-03-menu-instalacion.png` — menú principal del instalador en modo texto.
- `solaris-04-hostname.png` — definición del hostname (`solaris`).
- `solaris-05-network.png`, `solaris-05b-network-method.png` — configuración de red y método de configuración.
- `solaris-06-disks.png` — selección de los discos de destino.
- `solaris-07a-timezone-region.png`, `solaris-07b-timezone-bogota.png` — zona horaria: región América, ciudad Bogotá (`America/Bogota`).
- `solaris-07c-locale.png`, `solaris-07d-territory.png`, `solaris-07e-datetime.png`, `solaris-07f-keyboard.png` — locale en español, territorio, fecha/hora y teclado **Latin-American**.
- `solaris-08-users.png` — credenciales del usuario `root`; `solaris-08b-support-registration.png` — opción de registro de soporte.
- `solaris-09-summary.png` — resumen de configuración antes de instalar.
- `solaris-10-instalando.png` — instalación en curso.
- `solaris-11-completado.png` — instalación finalizada.
- `solaris-12-login.png` — primer login en el sistema instalado (`root` / `solaris1`).
- `solaris-13-sistema.png` — sistema operativo funcionando.

- Paquetes instalados: solo los necesarios para operación básica y conectividad de red.
- Archivos generados durante la instalación por el software de virtualización y su propósito (`.vmx`, `.vmdk`, `.nvram`, `.vmsd`, `.vmxf`, logs...).
- ¿Es posible convertir una VM de VMware a VirtualBox y viceversa? (OVF/OVA, `vmware-vdiskmanager`, `VBoxManage clonehd`...)

#### 3.2.2 Usuarios y grupos

En cada sistema Unix (Slackware y Solaris) se crearon 4 usuarios con una descripción significativa (campo `-c`), con su directorio home dentro de `/usuarios` en la raíz del filesystem y perteneciendo a **un solo grupo**: los usuarios 1 y 2 (`claudia`, `john`) al grupo Accounting, y los usuarios 3 y 4 (`fabian`, `diego`) al grupo IT.

**Slackware 15.0**

En Slackware los nombres de grupo no pueden contener mayúsculas: el `shadow-utils` de la distribución rechaza `groupadd Accounting` con `'Accounting' is not a valid group name`. Por eso los grupos se crearon en minúsculas: `accounting` e `it`.

Comandos ejecutados (como `root`, o con `sudo` desde el usuario `vagrant`):

```bash
# Directorio base de los homes
mkdir -p /usuarios

# Grupos (en minúsculas por la limitación de shadow-utils)
groupadd accounting
groupadd it

# Usuarios 1 y 2 -> solo accounting
useradd -d /usuarios/claudia -m -c "Claudia - usuario con el nombre de la profesora" -g accounting claudia
useradd -d /usuarios/john    -m -c "John - usuario con el nombre del profesor"     -g accounting john

# Usuarios 3 y 4 -> solo it
useradd -d /usuarios/fabian -m -c "Fabian - usuario con el nombre del profesor" -g it fabian
useradd -d /usuarios/diego  -m -c "Diego - usuario con el nombre del profesor"  -g it diego

# Asignar contraseña a cada usuario
passwd claudia
passwd john
passwd fabian
passwd diego
```

Significado de las opciones: `-d` define la ruta del home; `-m` lo crea y copia las plantillas de `/etc/skel`; `-c "..."` guarda la descripción del usuario (visible en el campo GECOS de `/etc/passwd`); `-g` fija el grupo **primario**, con lo que cada usuario queda en ese único grupo (cumple la consigna "solo Accounting / solo IT", sin grupos secundarios). Si hubiera que corregir algo posteriormente, se usa `usermod -g <grupo> <usuario>` para cambiar el grupo primario o `groupdel <grupo>` para eliminar un grupo vacío.

Resultado verificado (04/08/2026):

| Usuario | uid | Grupo primario | gid | Home |
|---|---|---|---|---|
| claudia | 1001 | accounting | 1002 | /usuarios/claudia |
| john | 1002 | accounting | 1002 | /usuarios/john |
| fabian | 1003 | it | 1003 | /usuarios/fabian |
| diego | 1004 | it | 1003 | /usuarios/diego |

Verificación con `id`, `getent` y `ls`:

```bash
# id claudia
uid=1001(claudia) gid=1002(accounting) groups=1002(accounting)

# getent group accounting
accounting:x:1002:

# ls -ld /usuarios
drwxr-xr-x 3 root root 4096 /usuarios

# ls -la /usuarios
drwxr-xr-x  2 claudia accounting 4096 ... claudia
```

Notas de la ejecución:
- El acceso a la VM es con el usuario `vagrant` (SSH o consola). Desde esa cuenta, el PATH **no** incluye `/usr/sbin` (Slackware solo lo agrega al PATH de root), por lo que `sudo groupadd` falla con `sudo: groupadd: command not found`. Se resolvió logueándose como `root` o invocando la ruta completa: `sudo /usr/sbin/groupadd it`, `sudo /usr/sbin/useradd ...`.
- `groupadd accounting` puede responder "already exists" (el grupo existía de una prueba anterior); no es un error, el grupo queda correcto.

**Solaris 11.4**

En Solaris los nombres de grupo sí admiten mayúsculas, por lo que los grupos se crearon como pide el lab: `Accounting` (GID 100) e `IT` (GID 101). Los nombres de usuario van en minúsculas.

Comandos ejecutados (como `root` en la consola de la VM):

```bash
# Directorio base de los homes
mkdir -p /usuarios

# Grupos
groupadd Accounting
groupadd IT

# Usuarios 1 y 2 -> solo Accounting
useradd -d /usuarios/claudia -m -c "Claudia - usuario con el nombre de la profesora" -g Accounting -s /usr/bin/bash claudia
useradd -d /usuarios/john    -m -c "John - usuario con el nombre del profesor"     -g Accounting -s /usr/bin/bash john

# Usuarios 3 y 4 -> solo IT
useradd -d /usuarios/fabian -m -c "Fabian - usuario con el nombre del profesor" -g IT -s /usr/bin/bash fabian
useradd -d /usuarios/diego  -m -c "Diego - usuario con el nombre del profesor"  -g IT -s /usr/bin/bash diego

# Asignar contraseña a cada usuario
passwd claudia
passwd john
passwd fabian
passwd diego
```

Mismas opciones que en Slackware, con dos diferencias de sintaxis: `-s /usr/bin/bash` define el shell de login (por defecto Solaris usa `/usr/bin/sh`), y el directorio padre `/usuarios` debe existir antes de `useradd -m` (si falta, `useradd` falla con `UX: useradd: ERROR: ... /usuarios: No such file or directory`; el `mkdir -p` del paso 1 lo resuelve).

Resultado verificado (04/08/2026):

| Usuario | uid | Grupo primario | gid | Home |
|---|---|---|---|---|
| claudia | 100 | Accounting | 100 | /usuarios/claudia |
| john | 101 | Accounting | 100 | /usuarios/john |
| fabian | 102 | IT | 101 | /usuarios/fabian |
| diego | 103 | IT | 101 | /usuarios/diego |

La verificación se hizo con los mismos comandos (`id <usuario>`, `getent group Accounting IT`, `ls -la /usuarios`), comprobando que cada home pertenece a su usuario y a su grupo, y que cada usuario aparece en un solo grupo.

**Diferencia entre ambos sistemas:** más allá de la limitación de mayúsculas de Slackware, los UID/GID de Solaris comienzan en 100 (numeración del instalador), mientras que Slackware los asigna desde 1000/1001; en el resto, la sintaxis y el resultado final son equivalentes.

#### 3.2.3 Sistema de archivos
- ¿Qué es el sistema de archivos?
- ¿Cuál se usó en la instalación? **Slackware 15.0: ext4**; **Solaris 11.4: ZFS** (el instalador de Solaris crea el pool `rpool` sobre el disco de destino por defecto).
- Características de cada uno.

#### 3.2.4 Red

En el hogar la red se configuró automáticamente por DHCP en modo bridge: en Slackware quedó registrada la configuración DHCP y se ejecutaron pruebas de ping con 0 % de pérdida. La red de la universidad, en cambio, **no tiene DHCP**: es una red estática (10.2.0.0/16, gateway y DNS 10.2.65.1, dominio `is.escuelaing.edu.co`) en la que cada equipo debe configurarse a mano.

- ¿Qué significan "Bridge Mode" y "NAT Mode"?
  - **Bridge:** la VM comparte la tarjeta de red física y aparece en la LAN como un equipo más, con su propia dirección IP; los demás equipos la ven directamente.
  - **NAT:** la VM sale a la red a través del anfitrión, que traduce las direcciones; la VM queda oculta detrás del host y solo tiene salida, no es alcanzable desde fuera.
- Configuración manual (estática):
  - IP: `10.2.78.n` (rango asignado por el instructor; sin duplicar entre sistemas) → Slackware=`10.2.78.64`, Windows Core=`10.2.78.66`, Windows GUI=`10.2.78.67`, Android=`10.2.78.68`, host=`10.2.78.69`; Solaris=`10.2.78.65`
  - Máscara: `255.255.0.0`
  - Gateway: `10.2.65.1`
  - DNS: `10.2.65.1`

**Configuración estática en Slackware 15.0 (editada con nano)**

En Slackware la configuración de red se edita en `/etc/rc.d/rc.inet1.conf` con el editor `nano` (más amigable que `vi`).

1. Abrir el archivo de red:
   ```bash
   nano /etc/rc.d/rc.inet1.conf
   ```
2. Dentro de nano, con las flechas, se buscaron y modificaron 4 valores (guardar con `Ctrl+O`, salir con `Ctrl+X`):

   | Línea | Valor |
   |---|---|
   | `USE_DHCP[0]="yes"` | `USE_DHCP[0]="no"` |
   | `IPADDR[0]=""` | `IPADDR[0]="10.2.78.64"` |
   | `NETMASK[0]=""` | `NETMASK[0]="255.255.0.0"` |
   | `GATEWAY=""` (agregada al final) | `GATEWAY="10.2.65.1"` |

3. El DNS se configuró en `/etc/resolv.conf` (también con nano). En Slackware este archivo NO es un enlace a resolvconf, por lo que la edición directa persiste:
   ```
   nameserver 10.2.65.1
   ```
4. Aplicar y verificar:
   ```bash
   /etc/rc.d/rc.inet1 restart
   ip addr show
   ip route show
   ```
   Resultado verificado: `eth0` con `10.2.78.64/16` y ruta por defecto `default via 10.2.65.1`.

5. Para alternar entre la red de la universidad (estática) y la del hogar (DHCP/NAT), se dejaron dos scripts dentro del sistema: `/usr/local/bin/uni` (aplica la estática) y `/usr/local/bin/casa` (vuelve a DHCP).

**Configuración estática en Solaris 11.4 (comandos `ipadm`)**

Solaris 11 usa el modelo SMF/`ipadm` (no archivos de script como rc.inet1.conf); la IP estática se verificó con `ipadm show-addr`.

1. Ver y eliminar la configuración DHCP existente:
   ```bash
   ipadm show-addr
   ipadm delete-addr net0/v4
   ```
2. Crear la dirección estática y el alias de red NAT:
   ```bash
   ipadm create-addr -T static -a local=10.2.78.65/16 net0/v4
   ipadm create-addr -T static -a local=10.0.2.15/24 net0/v4nat
   ```
3. Ruta por defecto persistente y DNS:
   ```bash
   route -p add default 10.2.65.1
   echo "nameserver 10.2.65.1" > /etc/resolv.conf
   ```
4. Verificación: `ipadm show-addr` muestra `net0/v4` = `10.2.78.65/16` estática.
5. Scripts de alternancia uni/casa: `/root/uni.sh` y `/root/casa.sh`.
##### Pruebas de conectividad en la red de la universidad

Las pruebas se ejecutaron en la red del laboratorio con las direcciones estáticas de la sección anterior; los resultados se resumen a continuación:

- **Host (portátil físico):** `10.2.78.69/16` con gateway y DNS `10.2.65.1`, configurado con `netsh` sobre el adaptador Ethernet.
- **Slackware (10.2.78.64):** estática en `/etc/rc.d/rc.inet1.conf` y DNS en `/etc/resolv.conf`; la verificación de la interfaz y de las rutas confirmó eth0 con `10.2.78.64/16` y ruta por defecto `default via 10.2.65.1` (la interfaz conserva además el alias NAT `10.0.2.15/24` agregado en `rc.local` para el escenario del hogar).
- **Windows Server Core (10.2.78.66):** estática aplicada con `netsh`. Como Windows bloquea el ping entrante por defecto, se habilitó el ICMP en el firewall (`netsh advfirewall firewall add rule` para `icmpv4:8`); la IP se verificó con `ipconfig` (hostname `WIN-O95R63RBHK9`).
- **Windows Server GUI (10.2.78.67):** estática aplicada con `netsh` (hostname `WIN-3VMPCF0KCDN`).
- **Android (10.2.78.68):** IP estática sobre la interfaz ethernet `wifi_eth` de android-x86. Android no ofrece la configuración estática estándar desde la consola de emergencia, por lo que se usó el *policy routing* de Linux con una tabla propia (tabla 97):
  - `ip rule add from all lookup main pref 50`
  - `ip route add default via 10.2.65.1 dev wifi_eth table 97`
  - `ip route add 10.2.0.0/16 dev wifi_eth src 10.2.78.68 table 97`
  - **Limitación documentada:** la resolución DNS por nombre no funciona desde la consola de emergencia (Android sin el servicio `netd` no consulta el DNS configurado): el ping por IP funciona, el ping por nombre no resuelve.
- **Solaris (10.2.78.65):** instalado y probado; IP estática con `ipadm`, pings OK.

Tabla de resultados reales (0 % de pérdida de paquetes en todas las pruebas OK):

| Prueba | Slackware .64 | Windows Core .66 | Windows GUI .67 | Android .68 | Solaris .65 |
|---|---|---|---|---|---|
| IP propia | 10.2.78.64/16 | 10.2.78.66/16 | 10.2.78.67/16 | 10.2.78.68/16 (`wifi_eth`) | 10.2.78.65/16 |
| Ping a la propia IP | OK — 0 % pérdida | — | — | — | OK — 0 % pérdida |
| Ping al gateway (10.2.65.1) | OK — 0 % pérdida | OK — 0 % pérdida | OK — 0 % pérdida | OK | OK — 0 % pérdida |
| Ping externo (8.8.8.8) | OK — 0 % pérdida | OK — 0 % pérdida | OK — 0 % pérdida | OK | OK — 0 % pérdida |
| Ping inter-VM | OK a Core (.66) | OK a Slackware (.64) y GUI (.67) | OK a Slackware (.64) | OK a Slackware (.64) | OK — 0 % pérdida |
| Resolución DNS (`ping www.google.com`) | OK — 0 % pérdida | OK — 0 % pérdida | OK — 0 % pérdida | No resuelve por nombre (limitación de Android) | OK |

Latencia media medida desde Slackware: 1,1 ms al gateway, 5,2 ms a 8.8.8.8 y 4,4 ms a `www.google.com` (RTT máx. 6 ms).

Pruebas OK (0 % de pérdida de paquetes): gateway, 8.8.8.8, `www.google.com` e inter-VM entre todos los sistemas.

#### 3.2.5 Comparación de experiencias de instalación

Ambos sistemas se instalaron en modo texto, sin entorno gráfico, sobre VMware. La experiencia fue muy distinta:

| Aspecto | Slackware 15.0 | Solaris 11.4 |
|---|---|---|
| Instalador | Script de consola con series de paquetes | Text Installer guiado (menús paso a paso) |
| Dificultad | Alta: cada decisión (particionado, series, arranque) es manual | Baja-media: el asistente guía todo el proceso |
| Paquetes | Series (`a`, `ap`, `d`, `l`, `n`, `x`, `xap`...); sin resolución automática de dependencias (`installpkg`) | Selección por grupos; IPS (`pkg`) resuelve dependencias |
| Tiempo | Largo: varias pasadas y correcciones (parche de `INSTALL.SH`, reinstalación, problema de arranque por PAE) | Corto: una sola pasada guiada |
| Control | Total sobre cada etapa | El instalador automatiza (pool ZFS `rpool`, boot environments) |

En Slackware la instalación fue un ejercicio de administración pura: hubo que diagnosticar el medio de instalación, parchear el script `INSTALL.SH` (los paquetes del ISO se reportaban corruptos), reinstalar el sistema y resolver un fallo de arranque por falta de soporte PAE (LILO no cargaba el kernel), para finalmente elegir las series de paquetes a instalar. El resultado es un sistema mínimo y totalmente conocido, sin gestor de dependencias: los paquetes se administran con `installpkg`/`upgradepkg`/`removepkg`.

En Solaris la instalación fue mucho más rápida y guiada: el Text Installer conduce paso a paso (idioma, hostname, red, discos, zona horaria, teclado, credenciales y resumen final), crea automáticamente el pool ZFS `rpool` y deja un sistema con gestión de paquetes IPS y boot environments (instantáneas del sistema de archivos raíz que permiten volver atrás).

Conclusión: Solaris privilegia la velocidad y la automatización; Slackware exige entender cada etapa, lo que lo hace más educativo, aunque más lento de instalar.

### 3.3 Comprensión y administración de los sistemas operativos

#### 3.3.1 Estructura de directorios
- Listar directorios, describir su contenido y comparar Slackware vs Solaris (evidencias de la estructura raíz de Slackware: `lab-evidencias/slackware-estructura-raiz.png`, `lab-evidencias/slackware-estructura-raiz-1.png` y `lab-evidencias/16-directorios.png`). En la raíz de Slackware se ven: `bin`, `boot`, `cdrom`, `dev`, `etc`, `home`, `lib`, `lost+found`, `media`, `mnt`, `opt`, `root`, `run`, `sbin`, `tmp`, `tmpmount`, `usr`, `var` y `usuarios`.
  - **Archivos de configuración (`/etc`):** texto plano editable por el administrador: `/etc/passwd`, `/etc/shadow`, `/etc/resolv.conf` y `/etc/rc.d/rc.inet1.conf` en Slackware; en Solaris la red vive en `/etc/inet` y los servicios en `/etc/svc`. Es la "memoria" de la configuración del sistema.
  - **Ejecutables (`/bin`, `/sbin`, `/usr/bin`, `/usr/sbin`):** los programas del sistema están separados por función y por orden de montaje: `/bin` y `/sbin` contienen lo esencial para arrancar y reparar el sistema antes de montar `/usr` (en Slackware 15 son enlaces a `usr/bin` y `usr/sbin`, aunque la convención se conserva); `/usr/bin` tiene los programas de uso general y `/usr/sbin` las herramientas de administración (reservadas a root). Varias ubicaciones = jerarquía histórica: lo mínimo para el arranque vs. el resto del sistema.
  - **Logs (`/var/log`):** aquí se registran los eventos del sistema (ver 3.3.2): en Slackware `/var/log/syslog`, `/var/log/messages` y `/var/log/secure`; en Solaris `/var/adm/messages` y `/var/adm/utmpx`.
  - **Montaje de dispositivos externos (`/mnt`, `/media`):** `/mnt` para montajes manuales (el USB de la prueba: `mount /dev/sdb1 /mnt/usb`) y `/media` para medios removibles montados automáticamente.
- Conectar una USB y hacerla visible en la VM: se emuló una USB en Slackware (disco virtual de 512 MiB adjuntado a la VM, visible como `VBOX HARDDISK`); flujo completo en `lab-evidencias/usb/slackware-usb.txt`:
  1. El dispositivo aparece como `/dev/sdb` (512 MiB, 1048576 sectores) y se particiona con `fdisk /dev/sdb`.
  2. Formateo ext4: `mkfs.ext4 /dev/sdb1` → crea el journal ("Creating journal (4096 blocks): done") y los superblocks ("Writing superblocks and filesystem accounting information: done").
  3. Punto de montaje y montaje: `mkdir -p /mnt/usb` y `mount /dev/sdb1 /mnt/usb` → el dispositivo queda montado (`/dev/sdb 488M 24K ... 1% /mnt/usb`).
  4. Copia de un archivo de prueba: `cp evidencia.txt /mnt/usb/` → aparece `evidencia.txt` (23 bytes) junto al directorio `lost+found`.
  5. Desmontaje: `umount /mnt/usb` → "sdb desmontado OK".
  - Los puntos de montaje estándar para dispositivos externos en Slackware son `/mnt` (montajes manuales) y `/media` (medios removibles).
- Diferencias observadas entre ambos sistemas: Slackware presenta la estructura clásica de Linux (`/boot`, `/lib`, `/lost+found`, `/media`, `/mnt`, `/opt`, `/srv`, `/tmp`, `/home`); Solaris añade directorios propios de SunOS (`/kernel` y `/platform` con los módulos del kernel, `/devices` con los nodos de dispositivo gestionados por devfs, `/etc/inet` para la red y `/var/adm` para los logs del sistema). Ambos siguen el estándar común de `/etc`, `/bin`, `/usr`, `/var`, `/tmp` y `/root`.

#### 3.3.2 Logs y syslog
- ¿Qué son los archivos de log? Archivos donde el sistema y los servicios registran eventos (arranque del kernel, inicios de sesión, errores de red, avisos de aplicaciones), cada entrada con fecha/hora, origen y mensaje.
- ¿Qué es syslog? Protocolo y servicio de registro central de eventos. Archivos principales: en Slackware `/var/log/syslog`, `/var/log/messages` y `/var/log/secure` (inicios de sesión y `sudo`); en Solaris `/var/adm/messages` (syslog del sistema) y `/var/adm/utmpx`/`wtmpx` (sesiones). En Slackware el demonio es `syslogd`; en Solaris el servicio SMF `svc:/system/system-log`.
- Tipos de información registrada y estructura de una entrada: fecha/hora, hostname, programa (o `kernel`) con su PID y el mensaje; en Solaris las entradas incluyen además un ID de evento (`[ID 936769 kern.info]`).
- Cinco ejemplos reales de eventos registrados:
  1. **Kernel (Slackware)** — mensajes del kernel con VirtualBox Guest Additions: `Aug 5 20:24:19 slackware kernel: ... main 7.2.12 r174389 started. Verbose level = 0` (`lab-evidencias/logs/slackware-syslog.txt`).
  2. **sshd/sudo (Slackware)** — uso de `sudo` por el usuario `vagrant` para leer el log de seguridad: `Aug 6 03:00:14 slackware sudo: vagrant : PWD=/home/vagrant ; USER=root ; COMMAND=/usr/bin/tail -6 /var/log/secure`, seguido de `pam_unix(sudo:session): session opened for user root` (`lab-evidencias/logs/slackware-ssh.txt`).
  3. **Kernel (Solaris)** — detección de dispositivos en el arranque: `Aug 5 22:05:09 solaris genunix: [ID 936769 kern.info] pm0 is /pseudo/pm@0` (`lab-evidencias/logs/solaris-messages.txt`).
  4. **Red (Solaris)** — enlace de red activo: `Aug 5 22:05:22 solaris mac: [ID 435574 kern.info] NOTICE: e1000g0 link up, 1000 Mbps, full duplex` (`lab-evidencias/logs/solaris-messages.txt`).
  5. **sendmail (Solaris)** — aviso del MTA: `Aug 5 22:09:36 solaris sendmail[902]: [ID 702911 mail.crit] My unqualified host name (solaris) unknown; sleeping for retry` (`lab-evidencias/logs/solaris-messages.txt`).
- ¿Funciona syslog en los sistemas instalados? **Sí, en ambos**: en Slackware los eventos quedan en `/var/log/syslog`, `/var/log/messages` y `/var/log/secure` (evidencias `lab-evidencias/logs/slackware-syslog.txt` y `slackware-ssh.txt`); en Solaris en `/var/adm/messages` (evidencia `lab-evidencias/logs/solaris-messages.txt`).

#### 3.3.3 Permisos
- Cómo funcionan los permisos en cada sistema: tripleta r/w/x aplicada a propietario/grupo/otros, visible con `ls -l` (en Solaris los grupos aparecen como `Accounting`/`IT`); los valores rwx se traducen al modo octal (4/2/1). Solaris suma además el modelo ZFS/ACL.
- Modificación con representación simbólica (`chmod g+w`, `chmod u+x,g-w`) y numérica (`chmod 750`, `chmod 640`, `chmod 770`).
- Pruebas de impacto reales en **Slackware** (`lab-evidencias/logs/slackware-permisos.txt`):
  - Directorio `/lab-permisos` propiedad de `root:it`: `chmod` numérico (750 sobre el directorio en el proceso y 640 sobre `archivo.txt`) y simbólico `g+w`; estado final verificado: `drwxrwx--- 2 root it` (770).
  - **fabian** (grupo `it`) puede crear archivos: `touch /lab-permisos/fabian.txt` → OK (`FABIAN_OK`).
  - **claudia** (grupo `accounting`) no puede: `touch: cannot touch '/lab-permisos/claudia.txt': Permission denied`.
  - Archivo `archivo.txt` con 640 (`-rw-r----- root:root`): solo root lo lee. Tras `chgrp it` y permisos simbólicos de lectura/escritura al grupo, **fabian** logra leerlo y **claudia** sigue denegada (`Permission denied`).
  - Simbólico `chmod u+x,g-w` sobre el archivo → `-rwxr-----` (ejecución al propietario, escritura quitada al grupo).
- Pruebas de impacto reales en **Solaris** (`lab-evidencias/logs/solaris-permisos.txt`):
  - Directorio `/lab-permisos` con `chmod 770 root:IT` → `drwxrwx--- 2 root IT`.
  - **fabian** (grupo `IT`) crea (`FABIAN_OK`) y lee `archivo.txt` sin errores.
  - **claudia** (grupo `Accounting`) denegada: `touch: cannot stat /lab-permisos/claudia.txt: Permission denied` y `cat: cannot open /lab-permisos/archivo.txt: Permission denied`.
  - Simbólico `chmod g-w` aplicado para quitar escritura al grupo.
- Conclusión de la matriz de impacto: un usuario del grupo propietario del directorio (fabian/IT) puede crear y leer; uno ajeno (claudia/Accounting) recibe `Permission denied` en ambos sistemas, confirmando que los permisos funcionan igual en Slackware y Solaris.

### 3.4 Windows Server — Fase 1 (Server Core, sin interfaz gráfica)

Instalación de la edición **Server Core** (sin interfaz gráfica) en VMware, evidencias en `lab-evidencias/`:

- `windows-01-instalando.png` — instalación de Windows Server 2025 en curso (edición Core).
- `windows-02-sconfig-primer-arranque.png` — primer arranque con la herramienta **SConfig** activa (panel de configuración de Server Core).

Datos verificados de la instalación:

- Hostname temporal asignado por el instalador: `WIN-095R63R3HG`.
- Cuenta local `Administrator` con contraseña `Server2025!`.
- Dominio: `WORKGROUP` (la VM no se unió a ningún dominio).

Red y pruebas (detalle en la subsección "Pruebas de conectividad en la red de la universidad" de 3.2.4):

- Red estática aplicada con `netsh`: 10.2.78.66/16, GW 10.2.65.1, DNS 10.2.65.1.
- ICMP habilitado en el firewall (Windows bloquea el ping entrante por defecto): regla `netsh advfirewall` para `icmpv4:8`.
- Pruebas OK (0 % de pérdida): gateway, 8.8.8.8, `www.google.com` e inter-VM con Slackware (.64) y GUI (.67).

Consigna pendiente:

- Acceso remoto (RDP): [PENDIENTE: verificar el estado de RDP en la VM].

### 3.5 Windows Server — Fase 2 (Desktop Experience)

Instalación de la versión gráfica (Desktop Experience), evidencias en `lab-evidencias/`:

- `windows-gui-01-instalando.png` — instalación de Windows Server 2025 (edición Desktop Experience) en curso.
- OOBE (Out-of-Box Experience) completado: cuenta `Administrator` con contraseña `Server2025!`.
- Red: estática aplicada con `netsh` (10.2.78.67/16, GW y DNS 10.2.65.1). Pruebas OK (0 % de pérdida): gateway, 8.8.8.8, `www.google.com` e inter-VM con Slackware (.64).
- `windows-gui-02-escritorio-server-manager.png` — escritorio con **Server Manager** abierto y funcional.

**Usuarios y grupos (evidencia: `lab-evidencias/usuarios-windows/usuarios-creados.txt`)**

Se crearon los 4 usuarios con PowerShell (`New-LocalUser`), todos habilitados y con la descripción significativa pedida por el lab; los usuarios 1 y 2 se asignaron al grupo local `Accounting` y los usuarios 3 y 4 a `IT` (`New-LocalGroup` + `Add-LocalGroupMember`):

```powershell
New-LocalUser -Name claudia -Description "Usuario con el nombre de la profesora"
New-LocalUser -Name john    -Description "Usuario con el nombre del profesor"
New-LocalUser -Name fabian  -Description "Usuario con el nombre del profesor"
New-LocalUser -Name diego   -Description "Usuario con el nombre del profesor"

New-LocalGroup -Name Accounting
New-LocalGroup -Name IT

Add-LocalGroupMember -Group Accounting -Member claudia, john
Add-LocalGroupMember -Group IT -Member fabian, diego
```

Resultado verificado (05/08/2026): `claudia`, `john`, `fabian` y `diego` aparecen en la lista de usuarios locales con `Enabled = True`; el grupo `Accounting` contiene a `WIN-3VMPCF0KCDN\claudia` y `WIN-3VMPCF0KCDN\john`, y el grupo `IT` a `WIN-3VMPCF0KCDN\fabian` y `WIN-3VMPCF0KCDN\diego`.

**Permisos con ACL e `icacls` (evidencia: `lab-evidencias/usuarios-windows/permisos-acl.txt`)**

Sobre la carpeta `C:\LabPermisos` se asignaron niveles de permiso con `icacls` (con `/grant` y `/deny`) y se verificó la ACL final:

| Usuario | Nivel | Significado |
|---|---|---|
| claudia | `(OI)(CI)(F)` | Control total (Full) |
| john | `(OI)(CI)(R)` | Solo lectura (Read) |
| fabian | `(OI)(CI)(M)` | Modificar (Modify) |
| diego | `(OI)(CI)(N)` | Deny (denegar) |

`(OI)` = heredado por objetos (archivos) y `(CI)` = heredado por contenedores (subcarpetas). El propietario de la carpeta es `BUILTIN\Administrators`; el archivo de prueba `prueba.txt` hereda la misma matriz (marcas `(I)`): claudia F, fabian M, john R y diego N. En Windows la negación (Deny) tiene prioridad sobre los permisos concedidos, por lo que `diego` queda excluido del acceso.

**Visor de eventos — eventos 4624 y 4625 (evidencia: `lab-evidencias/usuarios-windows/eventos-seguridad.txt`)**

- **4625 (logon fallido):** un intento con contraseña incorrecta de `claudia` el 05/08/2026 19:58:49 y dos intentos sobre `Administrator` el 03/08/2026, con estado `%%2313` (credenciales inválidas).
- **4624 (logon exitoso):** `claudia` el 05/08/2026 19:59:02, `Administrator` a las 19:58:25 y la cuenta `SYSTEM` a las 19:59:07.

**Windows Registry (evidencia: `lab-evidencias/usuarios-windows/registry.txt` y `registry-editor.png`)**

- Qué es: base de datos jerárquica donde Windows y las aplicaciones guardan su configuración, organizada en colmenas (*hives*). La colmena principal es HKLM (`HKEY_LOCAL_MACHINE`), con las claves `BCD00000000`, `HARDWARE`, `SAM`, `SECURITY`, `SOFTWARE` y `SYSTEM`.
- Ejemplos verificados: el hostname está en `HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName` → `WIN-3VMPCF0KCDN`; la ruta de instalación en `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ProgramFilesDir` → `C:\Program Files`.
- Edición con `regedit` (captura: `lab-evidencias/usuarios-windows/registry-editor.png`): la herramienta gráfica muestra el árbol de claves y valores; se editan con doble clic (también se puede en línea de comandos con `reg add` / `reg query`).

### 3.6 Android

Creación de la VM e instalación de **android-x86 9.0-r2** (kernel 4.9), evidencias en `lab-evidencias/`:

- `android-01-menu-instalacion.png` — menú de instalación de Android-x86.
- `android-02-instalador-elegir-particion.png` — elección de la partición de destino.
- `android-03-confirm-gpt.png` — confirmación del esquema de particiones GPT.
- `android-04-cfdisk.png` — particionado del disco con `cfdisk`.
- `android-05-particion-creada.png` — partición creada.
- `android-06-choose-partition-v2.png`, `android-07-choose-partition-auto.png` — selección de la partición para la instalación (incluido el modo automático).
- `android-08-instalado-exitoso.png` — instalación completada con éxito.
- `android-09-home-app-select.png` — selección de la aplicación de inicio (launcher).
- `android-10-escritorio.png`, `android-11-escritorio-final.png` — escritorio de Android funcionando.

Datos de la VM: 2 CPU, 2 GB de RAM, disco VDI de 16 GB, adaptador de red NAT y GRUB instalado en el disco (arranque directo desde disco). El arranque presentó un problema de visualización que se resolvió habilitando 128 MB de VRAM y la aceleración 3D en la configuración de la VM.

**Red (detalle en la subsección "Pruebas de conectividad en la red de la universidad" de 3.2.4)**

IP estática `10.2.78.68/16` sobre la interfaz ethernet `wifi_eth`, con *policy routing* en la tabla 97 (reglas de `ip rule`/`ip route` para salir por el gateway 10.2.65.1 y alcanzar la red 10.2.0.0/16). Pings OK al gateway, a 8.8.8.8 e inter-VM con Slackware (.64). Limitación documentada: la resolución DNS por nombre no funciona desde la consola de emergencia (Android sin `netd`). Evidencia: `lab-evidencias/red/android-pings-uni2.png`.

### 3.7 Conocimiento de línea de comandos
- ¿Qué es el shell? Intérprete de comandos que ejecuta programas y da acceso a los servicios del sistema (login, tuberías, variables, scripts). En Unix es a la vez prompt interactivo y lenguaje de scripting; en Windows conviven `cmd` (interpretador heredado de MS-DOS) y PowerShell (orientado a objetos).
- Shells soportados, verificados con la lista de shells válidos del sistema (evidencia `lab-evidencias/shell/`):
  - **Slackware 15.0** (`slackware-comandos.txt`): bash, ksh, csh, tcsh, zsh, dash y ash (más `sh`); los ejecutables están en `/bin` y `/usr/bin`.
  - **Solaris 11.4** (`solaris-comandos.txt`): bash, ksh, csh, zsh y sh (`/usr/bin/bash`, `/usr/bin/ksh`, `/usr/bin/csh`, `/usr/bin/zsh`, `/usr/bin/sh`).
  - **Windows Server 2025** (`windows-core-comandos.txt`): `cmd.exe` (Windows 10.0.26100) y PowerShell 5.1 (5.1.26100.1591).
- Diferencias: en Unix cada shell es un programa distinto con su propia sintaxis; Solaris usa históricamente sh/ksh/csh y Slackware incluye la familia completa. En Windows, `cmd` manipula texto plano y PowerShell trabaja con objetos; los homólogos de los comandos Unix (`dir`, `copy`, `findstr`, `where`) son menos potentes para procesar texto.
- Comandos (tabla comparativa Linux/Unix vs Windows):

| Tarea | Linux/Unix | Windows |
|---|---|---|
| Cambiar de directorio | `cd` | `cd` |
| Listar archivos | `ls -la` | `dir` |
| Copiar/mover archivo | `cp`, `mv` | `copy`, `move` |
| Ver contenido sin editar | `cat` | `type` |
| Editar un archivo | `vi`/`nano` | `notepad` |
| Primeras/últimas líneas | `head`, `tail` | `Get-Content -First/-Last` (PowerShell) |
| Buscar palabra en archivo | `grep` | `findstr` / `Select-String` |
| Localizar un archivo | `find`, `locate` | `where` / `Get-ChildItem -Recurse` |

- Ejemplos de uso de los 8 comandos con salidas reales abreviadas (evidencia `lab-evidencias/shell/`):

  **Slackware 15.0** (prompt `$`):

  ```bash
  $ cd /tmp
  /tmp

  $ ls -la /usuarios
  claudia (accounting), john, fabian, diego

  $ mv archivo.txt renombrado.txt
  -rwxr----- 1 root root /tmp/renombrado.txt

  $ cat archivo.txt
  slackware

  $ echo "linea-anadida" >> archivo.txt
  linea-anadida

  $ tail /etc/passwd
  root:x:0:0:...
  diego:x:1004:...

  $ grep claudia /etc/passwd
  claudia:x:1001:1002:...

  $ find /usuarios -name .screenrc
  4 archivos
  ```

  **Solaris 11.4** (prompt `$`):

  ```bash
  $ cd /tmp
  /tmp

  $ ls -la /usuarios
  claudia (Accounting), john, fabian, diego

  $ mv archivo.txt renombrado.txt
  -rwxr----- 1 root root /tmp/renombrado.txt

  $ cat archivo.txt
  solaris

  $ echo "linea-anadida" >> archivo.txt
  linea-anadida

  $ tail /etc/passwd
  root:x:0:0:Super-User
  diego:x:103:...

  $ grep claudia /etc/passwd
  claudia:x:100:100:...

  $ find /usuarios -name .profile
  .profile de cada usuario
  ```

  **Windows Server 2025** (prompt `C:\>`):

  ```bash
  C:\> cd \
  C:\

  C:\> dir C:\LabPermisos
  prueba.txt  20 bytes

  C:\> copy archivo.txt copia.txt
  1 file(s) copied.

  C:\> move archivo.txt renombrado.txt
  renombrado.txt

  C:\> type archivo.txt
  archivo-de-prueba

  C:\> echo linea-anadida >> archivo.txt
  linea-anadida

  C:\> Get-Content -Last hosts
  localhost

  C:\> findstr localhost hosts
  localhost

  C:\> where notepad
  C:\Windows\System32\notepad.exe
  ```

Nota: los ejemplos se ejecutaron y verificaron en los tres sistemas.

---

## 4. Uso y aplicaciones

- **Administración de servidores Unix y Windows:** lo aprendido permite administrar servidores sin interfaz gráfica: configuración de red estática, usuarios y grupos, servicios y línea de comandos. Slackware y Windows Server Core se administran por consola (SSH y SConfig), el modelo que se encuentra en servidores de archivos, DNS, correo y bases de datos reales.
- **Monitoreo con logs:** syslog (Slackware y Solaris) y el Visor de eventos (Windows) permiten detectar fallos de hardware y red, errores de servicios (sendmail, sshd) e intentos de acceso no autorizados (eventos 4624/4625, log de sudo), base de la auditoría de seguridad.
- **Gestión de usuarios y permisos:** la creación de usuarios y grupos con home en `/usuarios` y los permisos por grupo (`chmod`/ACL/`icacls`) aplican el principio de menor privilegio: en una empresa cada departamento (Accounting/IT) accede solo a sus recursos.
- **Virtualización en infraestructura empresarial y cloud:** un solo servidor físico consolidado en varias VM (menos hardware, menos energía), entornos de prueba aislados, instantáneas y migración entre hipervisores (OVF/OVA), y la base del modelo IaaS de las nubes públicas: el hipervisor es el componente sobre el que se construye la elasticidad y la multitenencia; los contenedores lo complementan para los microservicios.

---

## 5. Conclusiones

[Borrador provisional; se ajustará al cerrar el laboratorio.]

- Se instalaron y dejaron operativos cinco sistemas sobre un único equipo: Slackware 15.0, Solaris 11.4, Windows Server 2025 (Core y Desktop Experience) y Android-x86 9.0-r2, cada uno con su instalador, su sistema de archivos y su modelo de administración.
- La virtualización demostró su valor práctico: consolidación de plataformas heterogéneas, recuperación ante errores (reinstalaciones y snapshots) y portabilidad entre hipervisores (formatos OVF).
- La red estática del laboratorio (sin DHCP) obligó a planificar las direcciones y a configurar cada equipo a mano; la conectividad quedó verificada con 0 % de pérdida en todas las pruebas de Slackware, Windows Core, Windows GUI y Android.
- Se documentaron particularidades reales de cada plataforma: Windows bloquea el ICMP entrante por firewall, Android requiere policy routing y no resuelve DNS por nombre desde la consola de emergencia, y Slackware impone limitaciones en los nombres de grupo.
- Los conceptos de permisos, logs y shells funcionan de forma equivalente entre Slackware y Solaris, con diferencias de implementación (ACL/ZFS, SMF, IPS).
- Pendiente: verificar RDP en Windows Server Core y ajustar estas conclusiones con los resultados finales.

---

## 6. Bibliografía

- Oracle. *Oracle Solaris 11.4 Documentation*. https://docs.oracle.com/en/solaris/solaris/11.4/
- Slackware Linux Project. *Slackware Linux 15.0 Documentation*. https://www.slackware.com/documentation/
- Microsoft. *Evaluation Center — Windows Server 2025*. https://www.microsoft.com/en-us/evalcenter/
- Android-x86 Project. *Android-x86 — Release 9.0-r2*. https://www.android-x86.org/
- Oracle. *Oracle VM VirtualBox Documentation*. https://www.virtualbox.org/wiki/Docs
- VMware (Broadcom). *VMware Docs — máquinas virtuales y conversión OVF*. https://docs.vmware.com/
- The Linux Foundation. *Filesystem Hierarchy Standard 3.0*. https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.pdf

---

## Anexo A — Asignación de IPs (10.2.78.n)

La red del laboratorio es 10.2.0.0/16, con gateway y DNS 10.2.65.1 y dominio `is.escuelaing.edu.co`. **NO tiene DHCP**: todas las direcciones se configuraron estáticamente en cada equipo.

| Máquina | IP | Notas |
|---|---|---|
| Host (portátil físico) | 10.2.78.69 | Estática (configurada con `netsh` sobre el adaptador Ethernet), GW y DNS 10.2.65.1 |
| Slackware | 10.2.78.64 | Estática (`rc.inet1.conf`), probada OK |
| Solaris | 10.2.78.65 | Estática (`ipadm`), GW y DNS 10.2.65.1 |
| Windows Server Core | 10.2.78.66 | Estática (`netsh`), probada OK; ICMP habilitado en el firewall |
| Windows Server GUI | 10.2.78.67 | Estática (`netsh`), probada OK |
| Android | 10.2.78.68 | Estática en `wifi_eth` con policy routing (tabla 97); DNS por nombre no resuelve |
| PC del laboratorio (referencia) | 10.2.254.6 | Equipo físico del aula, gateway 10.2.65.1 |

## Anexo B — Guion del video (punto 1)

Video del grupo: <https://youtu.be/6HnwGg-_QV0>

Guion para el video de hasta 5 minutos sobre virtualización. Estilo presentación hablada; cada bloque indica el tiempo aproximado.

**(0:00 – 0:30) Apertura**

Hola, y bienvenidos. En este video vamos a explicar qué es la virtualización, cómo funcionan los hipervisores, por qué son la base del cómputo en la nube y en qué se diferencian las máquinas virtuales de los contenedores. La idea central es sencilla: un solo computador físico puede ejecutar varios sistemas operativos a la vez, cada uno aislado de los demás, como si fueran computadores independientes.

**(0:30 – 1:15) Hipervisores: qué son y cómo se clasifican**

El software que hace posible esto es el hipervisor, también llamado monitor de máquina virtual. Es una capa que se ubica entre el hardware y los sistemas operativos invitados: reparte la CPU, la memoria, el disco y la red entre las máquinas, y garantiza que una máquina no interfiera con otra. Los hipervisores se clasifican en dos tipos. El Tipo 1, o bare-metal, se instala directamente sobre el hardware, sin un sistema operativo debajo: ejemplos son VMware ESXi, Microsoft Hyper-V, Xen y KVM, y es el modelo que usan los centros de datos. El Tipo 2, o hosted, corre como una aplicación sobre un sistema operativo anfitrión: VirtualBox y VMware Workstation, que es lo que usamos en el laboratorio para instalar Slackware, Solaris, Windows y Android.

**(1:15 – 2:00) Características y arquitectura**

Las características clave de un hipervisor son el aislamiento, la partición de recursos y la encapsulación. Aislamiento: si una máquina virtual falla o se infecta, las demás siguen funcionando. Partición: el hipervisor divide los recursos físicos entre todas las máquinas. Encapsulación: una máquina virtual completa es un conjunto de archivos, así que se puede copiar, respaldar o migrar como cualquier otro archivo. En cuanto a la arquitectura, cada máquina virtual cree tener su propio hardware: una CPU virtual, memoria virtual, un disco y una tarjeta de red virtuales. El hipervisor intercepta las instrucciones privilegiadas del sistema invitado y las ejecuta sobre el hardware real, apoyándose en las extensiones de virtualización de los procesadores actuales.

**(2:00 – 2:45) Cloud computing y su relación con los hipervisores**

Ahora, ¿qué es el cómputo en la nube? Es la entrega de recursos de cómputo, almacenamiento y software a través de internet, bajo demanda y con pago por uso. Hay tres modelos de servicio: IaaS, que ofrece máquinas virtuales y redes; PaaS, que ofrece la plataforma para desplegar aplicaciones; y SaaS, que ofrece el software completo. ¿Se usan hipervisores en la nube? Sí, definitivamente: cuando en AWS o Azure pides una máquina virtual, es un hipervisor el que la crea en segundos sobre un servidor físico compartido con otros clientes. La multitenencia y la elasticidad, las dos propiedades que definen a la nube, son posibles gracias a la virtualización.

**(2:45 – 3:15) Costos: servidor físico vs. nube**

En costos hay un tradeoff. Un servidor físico exige una inversión inicial alta en hardware y costos fijos de energía, enfriamiento y mantenimiento, y suele quedar sobredimensionado para los picos de carga. La nube elimina esa inversión: se paga por uso, sin mantenimiento y con elasticidad real. Pero el costo es continuo: si el servidor se usa al máximo todo el tiempo, a largo plazo la nube puede salir más cara que el hardware propio. La decisión depende del perfil de carga y del nivel de control que se necesite.

**(3:15 – 4:15) Contenedores vs. máquinas virtuales**

Finalmente, hablemos de los contenedores. Una máquina virtual virtualiza el hardware: cada VM carga su propio sistema operativo completo. Un contenedor, en cambio, virtualiza el sistema operativo: todos los contenedores comparten el kernel del anfitrión, y el aislamiento se logra con namespaces y cgroups, las herramientas del kernel de Linux. Por eso un contenedor pesa megabytes y arranca en segundos, mientras una máquina virtual pesa gigabytes y arranca en minutos; por eso en un servidor caben decenas de máquinas virtuales pero cientos o miles de contenedores. La contrapartida es el aislamiento: la frontera de una máquina virtual es mucho más fuerte que la de un contenedor. En la práctica no compiten: las máquinas virtuales aíslan plataformas completas y los contenedores despliegan microservicios sobre ellas.

**(4:15 – 4:45) Cierre**

En resumen: el hipervisor es el software que multiplica un servidor físico en varias máquinas virtuales; la nube pública se construye sobre hipervisores; los contenedores comparten el kernel y son la opción ligera para las aplicaciones. En el laboratorio aplicamos estos conceptos instalando y administrando varios sistemas sobre una sola computadora, y verificando su conectividad en una red real. Gracias por ver el video.

## Anexo C — Conversión a LaTeX

- Mapeo 1:1 de secciones a `\section` / `\subsection`.
- Tablas → `tabular` / `booktabs`; capturas → `\includegraphics` con `lab-evidencias/` como ruta.
