# Credenciales — Máquinas y motores de base de datos (Laboratorio No. 05)

> Documento interno de referencia del grupo. NO incluir en el informe entregable.
> Fuente de verificación: scripts SQL en `lab05/`, informes LaTeX de `informe-latex/`
> y `odd/tasks/lab05-*.md`. Complementa a `CREDENCIALES.md` (máquinas del Lab 01).

## Resumen por máquina

| Máquina (VM) | SO | Motor de base de datos | Acceso desde el anfitrión |
|---|---|---|---|
| `slackware-15.0` | Slackware 15.0 | PostgreSQL 14.24 | SSH `127.0.0.1:2222` · PostgreSQL `127.0.0.1:5432` |
| `windows-server-gui` | Windows Server 2025 | SQL Server 2025 Express (`SQLEXPRESS`) | SSH `127.0.0.1:2225` · SQL `127.0.0.1:1433` |
| `solaris-11.4` | Oracle Solaris 11.4 | PostgreSQL 12.22 (compilado desde fuente) | SSH `127.0.0.1:2223` · PostgreSQL `127.0.0.1:5433` |
| Amazon RDS (nube) | — | MySQL 5.7.44 | endpoint `.rds.amazonaws.com` (recurso borrado) |

Los reenvíos de puerto de VirtualBox están atados a `127.0.0.1`, de modo que los
motores no quedan expuestos a la red local.

---

## 1. PostgreSQL 14.24 — Slackware 15.0 (puntos 2.1 y 2.5)

### Acceso a la máquina

- **SSH**: `ssh -i .ssh/vagrant.key -p 2222 vagrant@127.0.0.1`
- **Consola / root**: `root` / `vagrant`
- **Usuario**: `vagrant` / `vagrant` (miembro de `wheel`, sudo sin contraseña)

### Motor

- Cluster: `/var/lib/pgsql/14/data` — puerto `5432`, autenticación `md5`, `listen_addresses = '*'`
- Conexión desde el anfitrión: `psql -h 127.0.0.1 -p 5432 -U <rol>`

| Rol | Contraseña | Base de datos | Alcance |
|---|---|---|---|
| `postgres` | `Postgres2026!` | — | superusuario del cluster |
| `camilo` | `Lab2026!` | `turismo_camilo` | **solo** su base |
| `juan` | `Lab2026!` | `turismo_juan` | **solo** su base |

- Tablas: `ciudades`, `sitios_turisticos`, `visitas`, `resenas`
- Aislamiento: `REVOKE ALL ... FROM PUBLIC` + `GRANT CONNECT` únicamente al dueño.

---

## 2. SQL Server 2025 Express — Windows Server 2025 (punto 2.2)

### Acceso a la máquina

- **SSH**: `ssh -i .ssh/gentle-ai -p 2225 Administrator@127.0.0.1`
- **Consola**: `Administrator` / `Server2025!`
- Hostname: `WIN-3VMPCF0KCDN`

### Motor

- Instancia: `SQLEXPRESS` — SQL Server 2025 Express 17.0.1000.7, puerto `1433`
- LoginMode mixto (SQL + Windows); TCP/IP y SQLBrowser activos; puerto fijado en 1433
- Conexión: `sqlcmd -S 127.0.0.1,1433 -U <login> -P <contraseña> -C`
  (`-C` es obligatorio: el ODBC Driver 18 exige TLS y el certificado es autofirmado)

| Login | Contraseña | Base de datos (dueño) | Alcance |
|---|---|---|---|
| `camilo` | `Lab2026!` | `agenda_camilo` | **solo** su base |
| `juan` | `Lab2026!` | `agenda_juan` | **solo** su base |

- Tablas: `categorias`, `materias`, `actividades`, `recordatorios`
- Aislamiento en 2 capas: `DENY CONNECT` a PUBLIC por base + `DENY VIEW ANY DATABASE` en `master`.

---

## 3. PostgreSQL 12.22 — Oracle Solaris 11.4 (punto 2.4)

### Acceso a la máquina

- **SSH**: `ssh -i .ssh/gentle-ai -p 2223 root@127.0.0.1` (o `admin@127.0.0.1`)
- **Consola / root**: `root` / `solaris1`
- **Usuario admin**: `admin` / `Admin2026!` (perfil `All`, `pfexec` → root)

### Motor

- Cluster: `/opt/lab05-pg/data` — puerto `5432`, `UTF8` / `en_US.UTF-8`, `listen_addresses = '*'`
- Conexión desde el anfitrión (reenvío `5433 → 5432`): `psql -h 127.0.0.1 -p 5433 -U <rol>`

| Rol | Contraseña | Base de datos | Alcance |
|---|---|---|---|
| `camilo` | `Lab2026!` | `series_camilo` | **solo** su base |
| `juan` | `Lab2026!` | `series_juan` | **solo** su base |

- Superusuario `postgres`: administración local como usuario de sistema `postgres`
  (no se documenta contraseña de base para este rol).
- Tablas: `plataformas`, `series`, `episodios`, `progreso`
- Aislamiento: `REVOKE ALL ... FROM PUBLIC` + `GRANT CONNECT` únicamente al dueño.

---

## 4. Amazon RDS — MySQL 5.7.44 (Sección 3, AWS)

- Identificador: `lab05-biblioteca-aguirre-rangel` — MySQL 5.7.44, clase `db.t3.micro`
- Base de datos: `biblioteca` — tablas: `autores`, `obras`, `ejemplares`, `prestamos`

| Usuario | Contraseña | Alcance |
|---|---|---|
| `admin` (master) | `Lab2026!` | administración de la base |

- Las credenciales de la aplicación viven como variables de entorno de Apache en
  `/etc/httpd/conf.d/lab05-env.conf` (no dentro del código PHP).
- **Estado: recursos BORRADOS** (RDS y EC2) al cerrar el laboratorio, para no consumir crédito.
- Las credenciales del Learner Lab de AWS Academy (cuenta `077928862576`, región `us-east-1`)
  son temporales, caducan cada ~4 h y **no se guardan en este documento**.

---

## 5. Azure SQL Database (punto 2.3)

- **No creado**: la suscripción de Azure for Students estaba deshabilitada
  (`ReadOnlyDisabledSubscription`). No hay credenciales asociadas.

---

## Convenciones

- Contraseña de laboratorio de los integrantes: `Lab2026!` (idéntica en los tres motores locales).
- Contraseña del superusuario PostgreSQL en Slackware: `Postgres2026!`.
- Las máquinas comparten los usuarios de sistema de `CREDENCIALES.md`; aquí solo se
  agregan los roles de cada motor de base de datos.

## Notas de seguridad

- Este documento es interno: no debe incluirse en el informe entregable.
- Publicarlo en un repositorio **público** expone las contraseñas. Mantenerlo en un
  repositorio privado o fuera del repositorio público.
- Las credenciales de AWS Academy son temporales y no se versionan.
