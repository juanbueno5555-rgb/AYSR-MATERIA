# Guía: Creación de usuarios y grupos — Laboratorio No. 01

> Documento de trabajo del grupo. Ejecutar en cada máquina cuando esté encendida.
> Credenciales de acceso en `CREDENCIALES.md`.
> Los 4 usuarios de ejemplo son: **claudia**, **john**, **fabian**, **diego** (cambiar si el grupo usa otros nombres).

## Reglas del laboratorio (sección 2.a)

- 4 usuarios por sistema Unix (Slackware y Solaris).
- Descripción significativa de cada usuario (`-c "..."`).
- Home directory = nombre de usuario, dentro de `/usuarios` en la raíz.
- Grupo **Accounting**: usuarios 1 y 2 → `claudia`, `john` (SOLO este grupo).
- Grupo **IT**: usuarios 3 y 4 → `fabian`, `diego` (SOLO este grupo).
- Windows Server GUI: crear los mismos 4 usuarios (Fase 2).
- Android: no aplica (no se crean usuarios).

---

## 1) Slackware 15.0 — VM `slackware-15.0`

Login: `root` / `vagrant` (consola de VirtualBox) o SSH:
`ssh -i .ssh/vagrant.key -p 2222 vagrant@127.0.0.1` y luego `su -`

Ejecutar como root (si estás logueado como `vagrant`, anteponé `sudo` a todo, o hacé `su -` y poné la clave `vagrant`), en orden:

```bash
# 1. Crear los grupos (en minúsculas — Slackware rechaza mayúsculas)
#    OJO: 'accounting' YA EXISTE (GID 1002); si sale "already exists" es normal.
sudo groupadd accounting
sudo groupadd it

# 2. Crear el directorio base de los homes (ya existe, no da error)
sudo mkdir -p /usuarios

# 3. Usuario 1 y 2 → SOLO grupo accounting
sudo useradd -d /usuarios/claudia -m -c "Claudia - usuario con el nombre de la profesora" -g accounting claudia
sudo useradd -d /usuarios/john    -m -c "John - usuario con el nombre del profesor"     -g accounting john

# 4. Usuario 3 y 4 → SOLO grupo it
sudo useradd -d /usuarios/fabian -m -c "Fabian - usuario con el nombre del profesor" -g it fabian
sudo useradd -d /usuarios/diego  -m -c "Diego - usuario con el nombre del profesor"  -g it diego

# 5. Asignar contraseña a cada usuario (pedirá escribirla 2 veces)
sudo passwd claudia
sudo passwd john
sudo passwd fabian
sudo passwd diego

# 6. Verificar
id claudia
id fabian
ls -la /usuarios
getent group accounting it
```

**ESTADO ACTUAL (verificado 2026-08-04):** los 4 usuarios YA existen con sus grupos correctos. Solo falta el paso 5 (`passwd`). Tabla de verificación esperada:

| Usuario | uid | grupo primario | gid | Home |
|---|---|---|---|---|
| claudia | 1001 | accounting | 1002 | /usuarios/claudia |
| john | 1002 | accounting | 1002 | /usuarios/john |
| fabian | 1003 | it | 1003 | /usuarios/fabian |
| diego | 1004 | it | 1003 | /usuarios/diego |

**Importante (verificado en la VM):**
- Los grupos van en **minúsculas**: `accounting`, `it`. `groupadd Accounting` falla con `'Accounting' is not a valid group name`.
- **Consola como `vagrant`**: tu PATH NO incluye `/usr/sbin` (Slackware solo lo agrega para root), por eso `sudo groupadd` da `sudo: groupadd: command not found`. Dos soluciones:
  - Loguearse como **root** (`root` / `vagrant`) en el login → PATH completo, sin sudo.
  - O usar la ruta completa: `sudo /usr/sbin/groupadd it`, `sudo /usr/sbin/useradd ...`.
  - O hacer `su -` (clave de root: `vagrant`).
- `groupadd accounting` puede decir "already exists" → es normal, ya existe del 1 de agosto.

### Explicación de cada flag (qué escribís y por qué)

**`useradd` — crear usuario** (el nombre del usuario va SIEMPRE al final):

| Flag | Qué significa | Qué hace | Ejemplo |
|---|---|---|---|
| `-d DIR` | *home directory* | Define la ruta del home del usuario (NO lo crea solo) | `-d /usuarios/claudia` |
| `-m` | *make home* | Crea el directorio home si no existe y copia los archivos de plantilla de `/etc/skel` | `-m` |
| `-c "TEXTO"` | *comment* | Guarda la descripción del usuario (lo que se ve en `finger` y en el campo GECOS de `/etc/passwd`) | `-c "Claudia - usuario con el nombre de la profesora"` |
| `-g GRUPO` | *primary group* | Define el grupo PRIMARIO del usuario. Con esto el usuario queda SOLO en ese grupo (cumple el lab) | `-g accounting` |
| `-G GRUPO1,GRUPO2` | *groups* | Agrega grupos SECUNDARIOS extra (con coma, sin espacios). NO lo necesitamos en el lab | `-G wheel` |
| `-s SHELL` | *shell* | Cambia el shell de login. Slackware usa `/bin/bash` por defecto, por eso no hace falta | `-s /bin/bash` |
| `-u UID` | *user id* | Fuerza un UID específico. Si no se pone, Slackware elige el siguiente libre (1001, 1002...) | `-u 1500` |
| `-e FECHA` | *expire* | Fecha de expiración de la cuenta (formato AAAA-MM-DD). Sin esto, la cuenta no expira | `-e 2026-12-31` |
| `-k DIR` | *skel* | Directorio de plantilla alternativo (solo con `-m`) | `-k /etc/skel` |

Ejemplo completo con todo lo que hace el lab:
```bash
useradd -d /usuarios/claudia -m -c "Claudia - usuario con el nombre de la profesora" -g accounting claudia
#         └─ home en /usuarios/claudia   └─ crea el home   └─ descripción visible en passwd   └─ grupo primario accounting   └─ NOMBRE (al final)
```

**`groupadd` — crear grupo:**

| Flag | Qué significa | Qué hace | Ejemplo |
|---|---|---|---|
| *(ninguno)* | — | Crea el grupo con el siguiente GID libre | `groupadd it` → GID 1003 |
| `-g GID` | *group id* | Fuerza un número de grupo específico | `groupadd -g 1500 it` |
| `-r` | *system* | Crea un grupo de sistema (GID < 1000, para servicios) | `groupadd -r mysql` |

**`passwd` — asignar contraseña:**

| Flag | Qué significa | Qué hace | Ejemplo |
|---|---|---|---|
| *(ninguno)* | — | Pide la nueva contraseña 2 veces y la guarda en `/etc/shadow` | `passwd claudia` |
| `-l` | *lock* | Bloquea la cuenta (agrega `!` al hash) | `passwd -l claudia` |
| `-u` | *unlock* | Desbloquea la cuenta | `passwd -u claudia` |
| `-e` | *expire* | Obliga a cambiar la contraseña en el próximo login | `passwd -e claudia` |

**`id` / `getent` — verificar:**

| Comando | Qué muestra | Ejemplo de salida esperada |
|---|---|---|
| `id claudia` | uid + grupo primario + grupos | `uid=1001(claudia) gid=1002(accounting) groups=1002(accounting)` |
| `getent group accounting` | línea del grupo en `/etc/group` | `accounting:x:1002:` |
| `ls -la /usuarios` | homes con propietario y grupo | `drwxr-xr-x 2 claudia accounting 4096 ... claudia` |

**`usermod` — modificar un usuario existente (si algo quedó mal):**

| Flag | Qué hace | Ejemplo |
|---|---|---|
| `-g GRUPO` | Cambia el grupo primario | `usermod -g accounting claudia` |
| `-c "TEXTO"` | Cambia la descripción | `usermod -c "Claudia - corregido" claudia` |
| `-l NUEVO` | Cambia el nombre de usuario | `usermod -l carolina claudia` |
| `-L` / `-U` | Bloquea / desbloquea la cuenta | `usermod -L claudia` |

**`groupdel` — borrar grupo** (no debe tener miembros):
```bash
groupdel accouting   # ← borramos así el grupo con typo que existía
```

---

## 2) Oracle Solaris 11.4 — VM `solaris-11.4`

Login: `root` / `solaris1` (solo consola de VirtualBox; SSH de root bloqueado).

Ejecutar como root, en orden (Solaris usa las mismas herramientas, con sintaxis ligeramente distinta):

```bash
# 1. Crear los grupos
groupadd Accounting
groupadd IT

# 2. Crear el directorio base de los homes
mkdir -p /usuarios

# 3. Usuario 1 y 2 → SOLO grupo Accounting
useradd -d /usuarios/claudia -m -c "Claudia - usuario con el nombre de la profesora" -g Accounting -s /usr/bin/bash claudia
useradd -d /usuarios/john    -m -c "John - usuario con el nombre del profesor"     -g Accounting -s /usr/bin/bash john

# 4. Usuario 3 y 4 → SOLO grupo IT
useradd -d /usuarios/fabian -m -c "Fabian - usuario con el nombre del profesor" -g IT -s /usr/bin/bash fabian
useradd -d /usuarios/diego  -m -c "Diego - usuario con el nombre del profesor"  -g IT -s /usr/bin/bash diego

# 5. Asignar contraseña a cada usuario
passwd claudia
passwd john
passwd fabian
passwd diego

# 6. Verificar
id claudia
id fabian
ls -la /usuarios
getent group Accounting IT
```

**ESTADO ACTUAL (verificado 2026-08-04):** los 4 usuarios YA existen con sus grupos correctos. Tabla de verificación esperada:

| Usuario | uid | grupo primario | gid | Home |
|---|---|---|---|---|
| claudia | 100 | Accounting | 100 | /usuarios/claudia |
| john | 101 | Accounting | 100 | /usuarios/john |
| fabian | 102 | IT | 101 | /usuarios/fabian |
| diego | 103 | IT | 101 | /usuarios/diego |

> **IMPORTANTE — teclado en Solaris:** la VM quedó con teclado **US-English** (cambiado con `kbd -s US-English`). El layout original Latin-American hacía que los guiones se escribieran como apóstrofes. Si algún comando con `-` falla raro, verificar con `kbd` (debe mostrar `US-English`).

**Explicación de opciones (`useradd` en Solaris):**
- `-d /usuarios/nombre` → home en `/usuarios/nombre`.
- `-m` → crea el home (el directorio padre `/usuarios` debe existir primero).
- `-c "descripción"` → descripción del usuario.
- `-g Accounting|IT` → grupo primario.
- `-s /usr/bin/bash` → shell de login bash (opcional; por defecto usa `/usr/bin/sh`).
- **OJO Solaris**: en Solaris los grupos SÍ pueden tener mayúsculas (`Accounting`, `IT` — ya existen con GID 100 y 101). Los nombres de usuario van en minúsculas.

> OJO Solaris: si `useradd` falla con "UX: useradd: ERROR: ... /usuarios: No such file or directory", el paso 2 (`mkdir -p /usuarios`) ya lo resolvió; verificarlo con `ls -ld /usuarios`.

---

## 3) Windows Server 2025 GUI — VM `windows-server-gui`

Login: `Administrator` / `Server2025!` (consola de VirtualBox o RDP).

### Opción A — PowerShell (recomendado para copiar/pegar)

Abrir **PowerShell como Administrador** (clic derecho → "Windows PowerShell (Admin)") y ejecutar:

```powershell
# 1. Crear los grupos locales
New-LocalGroup -Name "Accounting"
New-LocalGroup -Name "IT"

# 2. Crear los 4 usuarios (cambiar Contraseña123! por la que el grupo decida)
$pass = ConvertTo-SecureString "Contraseña123!" -AsPlainText -Force
New-LocalUser -Name "claudia" -FullName "Claudia" -Description "Usuario con el nombre de la profesora" -Password $pass -PasswordNeverExpires
New-LocalUser -Name "john"    -FullName "John"    -Description "Usuario con el nombre del profesor"   -Password $pass -PasswordNeverExpires
New-LocalUser -Name "fabian"  -FullName "Fabian"  -Description "Usuario con el nombre del profesor"   -Password $pass -PasswordNeverExpires
New-LocalUser -Name "diego"   -FullName "Diego"   -Description "Usuario con el nombre del profesor"   -Password $pass -PasswordNeverExpires

# 3. Usuario 1 y 2 → SOLO Accounting
Add-LocalGroupMember -Group "Accounting" -Member "claudia","john"

# 4. Usuario 3 y 4 → SOLO IT
Add-LocalGroupMember -Group "IT" -Member "fabian","diego"

# 5. Verificar
Get-LocalGroup
Get-LocalGroupMember -Group "Accounting"
Get-LocalGroupMember -Group "IT"
Get-LocalUser | Select-Object Name, Enabled
```

### Opción B — `net user` / `net localgroup` (cmd)

Abrir **cmd como Administrador** y ejecutar:

```cmd
:: 1. Crear usuarios (cambiar Contraseña123! por la que el grupo decida)
net user claudia Contraseña123! /add /fullname:"Claudia" /comment:"Usuario con el nombre de la profesora" /passwordchg:no
net user john Contraseña123! /add /fullname:"John" /comment:"Usuario con el nombre del profesor" /passwordchg:no
net user fabian Contraseña123! /add /fullname:"Fabian" /comment:"Usuario con el nombre del profesor" /passwordchg:no
net user diego Contraseña123! /add /fullname:"Diego" /comment:"Usuario con el nombre del profesor" /passwordchg:no

:: 2. Crear grupos y asignar
net localgroup Accounting /add
net localgroup IT /add
net localgroup Accounting claudia john /add
net localgroup IT fabian diego /add

:: 3. Verificar
net localgroup Accounting
net localgroup IT
```

> El lab (Fase 2) además pide: gestionar permisos con ACL (`icacls`), asignar niveles de permiso y revisar eventos en `eventvwr` — eso se documenta en el informe, es el siguiente paso del lab.

---

## 4) Windows Server 2025 Core — VM `windows-server-core`

La Fase 1 del lab **no pide crear usuarios** (solo instalación + red). Si el grupo quiere crearlos igual, usar la **Opción B** de arriba en la consola (`sconfig` → salir al cmd, o directo `cmd` desde la consola).

---

## 5) Android-x86 — VM `android-x86`

**No aplica**: Android no se administra con usuarios del sistema tipo Unix/Windows. El lab solo pide instalación + red. Dejar como está.

---

## Resumen de comandos por tarea

| Tarea | Slackware / Solaris | Windows (PowerShell) |
|---|---|---|
| Crear grupo | `groupadd <grupo>` | `New-LocalGroup -Name <grupo>` |
| Crear usuario | `useradd -d /usuarios/x -m -c "desc" -g <grupo> x` | `New-LocalUser -Name x -Password $pass` |
| Asignar a grupo | (ya va en `-g` al crear) | `Add-LocalGroupMember -Group <g> -Member x` |
| Contraseña | `passwd x` | en `New-LocalUser` o `net user x Clave /add` |
| Verificar | `id x` + `getent group` | `Get-LocalUser` + `Get-LocalGroupMember` |

## Pendientes del lab que siguen después de usuarios

- [ ] Configurar IP manual: `10.2.77.n` / máscara `255.255.0.0` / gateway `10.2.65.1` / DNS `10.2.65.1` (en las 4 VMs de red + Windows, cuando el instructor asigne el rango).
- [ ] Pruebas de conectividad (ping a la propia VM, gateway, 8.8.8.8, otra VM, `www.google.com`).
- [ ] Permisos y pruebas de impacto (sección 3.3.3 del informe).
- [ ] Logs / syslog (3.3.2).
- [ ] Windows: permisos ACL, Registry, Visor de eventos (Fase 2).
