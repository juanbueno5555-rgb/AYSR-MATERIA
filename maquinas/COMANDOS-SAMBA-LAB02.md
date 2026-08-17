# Comandos SAMBA — Lab 02 (documentados con máquinas en vivo)

> Servidor: Solaris 11.4 (`10.2.78.75`). Clientes: Slackware 15.0 (`10.2.78.74`) y Windows Server GUI (`10.2.78.76`).
> Red simulada de la uni: `lab-uni` (NIC2 internal network en cada VM).

---

## 1. Estados del servidor (en Solaris)

### Ver los procesos de Samba corriendo
```bash
ps -ef | grep smbd
```
Salida real:
```
root  2130  1   0 14:58:29 ?  0:00 /usr/sbin/smbd -D     <- proceso padre (acepta conexiones)
root  2142  2130  ...         0:00 /usr/sbin/smbd -D     <- hijo (por cada cliente conectado)
```

### Ver en qué puerto escucha (445 = SMB)
```bash
netstat -an | grep .445
```
Salida real:
```
*.445  *.*  ...  LISTEN                                    <- puerto abierto esperando clientes
10.2.78.75.445  10.2.78.76.49727  ...  ESTABLISHED         <- Windows conectado AHORA
```

### Validar la configuración
```bash
testparm
```
Salida real (resumen):
```
Server role: ROLE_STANDALONE
security = USER          # cada cliente se identifica con usuario+password
path = /export/compartido   # carpeta del disco de Solaris que se comparte
valid users = claudia admin # solo estos usuarios
read only = No              # share escribible
```

### Ver el archivo de configuración
```bash
cat /etc/samba/smb.conf
```

---

## 2. Usuarios SMB (separados de los del sistema)

### Listar usuarios que Samba reconoce
```bash
smbpasswd -L
pdbedit -L
```
Salida real:
```
claudia:100:Claudia - usuario con el nombre de la profesora
admin:104:
```

### Agregar / borrar / cambiar contraseña SMB
```bash
smbpasswd -a claudia     # agregar usuario SMB (pide password nueva)
smbpasswd -x claudia     # borrar usuario SMB
smbpasswd claudia         # cambiar contraseña SMB
```

> Los usuarios SMB viven en la base `tdbsam` de Samba, independiente de `/etc/shadow`.

---

## 3. Desde el cliente Slackware (smbclient)

### Enumerar los shares del servidor (ver el "menú")
```bash
smbclient -L //10.2.78.75 -U claudia
```

### Conectarse al share y operar archivos
```bash
smbclient //10.2.78.75/compartido -U claudia
# comandos dentro de la sesion smbclient:
#   ls                 lista archivos
#   put archivo-local  sube al servidor
#   get archivo-remoto baja del servidor
#   mkdir carpeta      crea carpeta
#   exit               sale
```

### Todo en una sola línea (sin sesión interactiva)
```bash
smbclient //10.2.78.75/compartido -U claudia -c 'ls; put /tmp/demo.txt demo.txt; get demo.txt /tmp/vuelta.txt'
```

Salida real:
```
putting file /tmp/demo.txt as \demo.txt (5.6 kb/s)   <- subió
getting file \demo.txt of size 52 as /tmp/vuelta.txt <- bajó
```

---

## 4. Desde el cliente Windows (net use)

```cmd
REM Conectar el share como unidad de red
net use \\10.2.78.75\compartido /user:claudia claudia123

REM Ver los archivos del share
dir \\10.2.78.75\compartido

REM Crear/editar un archivo dentro del share
echo Hola desde Windows > \\10.2.78.75\compartido\archivo.txt

REM Listar conexiones de red activas
net use

REM Desconectar
net use \\10.2.78.75\compartido /delete
```

---

## 5. Ver las sesiones activas (del lado del servidor)

```bash
smbstatus
```
Salida real:
```
Samba version 4.7.6
PID     Username  Group       Machine        Protocol  Signing
2142    claudia   Accounting  10.2.78.76     SMB3_11   AES-128-CMAC

Service      Macine       Connected at                      Signing
compartido   10.2.78.76   Mon Aug 17 15:02:40 2026 -05     AES-128-CMAC
```

Muestra: quién está conectado, desde qué IP, con qué versión de SMB y la firma (cifrado) usada.

---

## Conceptos clave (para la explicación del informe)

| Concepto | Explicación |
|---|---|
| **SMB** | Protocolo (lenguaje) de archivos de red de Windows |
| **SAMBA** | Programa open-source que implementa SMB en Unix/Linux/Solaris |
| **Share** | Carpeta publicada (`compartido` → `/export/compartido`) |
| **Puerto 445/TCP** | Dónde escucha el servidor SMB/Samba |
| **smbpasswd / tdbsam** | Base de usuarios SMB, separada del sistema |
| **security = user** | Autenticación con usuario+password (no anónimo) |
| **valid users** | Quiénes pueden entrar al share |
| **tree connect** | Conectarse a un share (entrar a la "mesa") |
| **smbclient** | Cliente SMB de línea de comandos |
| **net use** | Conectar un share desde Windows |
| **smbstatus** | Ver sesiones y conexiones activas |
| **SID** | Identificador único estilo Windows que Samba asigna a cada usuario |
| **ROLE_STANDALONE** | Servidor que gestiona su propia autenticación (sin AD) |
