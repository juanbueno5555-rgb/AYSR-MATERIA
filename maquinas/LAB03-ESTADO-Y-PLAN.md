# LABORATORIO 03 — Base Platform and Application Layer Protocols

**Grupo:** Camilo Aguirre + Juan David Rangel (2 estudiantes)
**Repo relacionado:** rama `lab03` / carpeta `laboratorios3/` (guía, resumen, evidencias, scripts, informe)
**Fecha de inicio:** 29/08/2026

---

## Qué pide el lab (y cómo lo queremos)

El lab tiene 3 partes: **DNS (BIND)**, **programación Shell** y **Amazon EC2**.

### 1. DNS con BIND — dominios del grupo

- Por ser grupo de 2, se configuran 2 dominios de prueba con nuestros nombres:
  - **`juan.com.it`** (reemplazo de student1.com.it)
  - **`camilo.org.uk`** (reemplazo de student2.org.uk)
- Cada dominio debe tener: 3 servidores con IPv4, 2 con IPv6, 2 alias (CNAME) IPv4 y 1 alias IPv6.
- Arquitectura decidida (los secundarios dan redundancia y cumplen el lab):

| Servidor | `juan.com.it` | `camilo.org.uk` |
|---|---|---|
| Solaris (.75 / intnet .11) | **Primario** (BIND) | Secundario (slave) |
| Slackware (.74 / intnet .10) | Secundario (slave) | **Primario** (BIND) |
| Windows GUI (.76 / intnet .13) | Secundario (rol DNS de Windows) | — |
| Windows Core (.77 / intnet .12) | — | Secundario (rol DNS de Windows) |

- Las transferencias de zona y pruebas entre VMs van por la red interna `lab-uni`
  (192.168.82.0/24) → funcionan SIEMPRE, estén en casa o en la uni.
- Ejercicios del lab ya cubiertos: resolución interna, externa (google), la prueba con el
  DNS de la escuela (10.2.65.1) — punto 7C — y forwarders de Windows apuntando al DNS de la uni.
- Video nslookup (máx 5 min): guion listo en `laboratorios3/GUION-VIDEO-NSLOOKUP-LAB03.md`
  (la parte C usa una foto de la salida real para no depender de la red de la uni).

### 2. Programación Shell (Solaris + Slackware)

- **(a) `schedult-task-script.sh`** — programa una tarea en cron con frecuencia y comando
  por línea de comandos, sin prompts: `./schedult-task-script.sh "*/1 * * * *" "comando"`.
- **(b) `menu-procesos.sh`** — menú: listar procesos (nombre, PID, %mem, %cpu), buscar,
  matar, reiniciar y salir.
- **(c) `files-script.sh`** — muestra los N archivos más pequeños menores a un tamaño
  recorriendo subdirectorios: `./files-script.sh 10 1GB`. Salida: nombre, ruta, tamaño.
- Los 3 scripts viven en `laboratorios3/scripts/` y ya se probaron en EC2 y/o VMs.
- En el Lab 02 quedó además Samba: **Solaris es el servidor** (share `compartido` →
  `/export/compartido`, usuario `claudia` / `Lab2026!`) con Windows y Slackware como
  clientes conectados (evidencia del 29/08).

### 3. Amazon EC2

- Se lanza una instancia **t2.micro / Amazon Linux 2023** (Free Tier) con key pair
  `lab03-key.pem` y conexión SSH desde Windows.
- En la instancia se prueba el Shell del lab (files-script ya corre ahí).
- Recomendado: Elastic IP para que la IP pública no cambie al detener/reiniciar.

---

## Cómo lo estamos haciendo (método)

1. **Evidencia real en cada paso**: comandos + salidas guardados en
   `laboratorios3/evidencias/` (DNS, Samba, EC2, nslookup 7C, scripts, forwarders, IPs uni).
2. **Informe en Markdown** (`laboratorios3/informe-laboratorio-03.md`) con la estructura
   metodológica de los labs anteriores, listo para transcribir a LaTeX → PDF.
3. **Video nslookup** con guion y fotos listas.
4. **VMs con snapshots** por etapa (`estado-dns-lab03`, `estado-uni-lab03`) para volver a
   un estado conocido en cualquier momento.

## Estado al 29/08 (en la uni)

- [x] IPs de la uni aplicadas en las 4 VMs (+ snapshot estado uni)
- [x] DNS: zonas maestras/esclavas en los 4 servidores, resolución interna y externa
- [x] Punto 7C (DNS de la escuela) con evidencia
- [x] Forwarders de Windows → 10.2.65.1
- [x] Samba: Solaris servidor, Windows (Z:/Y:) y Slackware (smbclient) conectados
- [x] EC2: instancia lanzada + SSH + files-script probado
- [x] Guion video nslookup + salidas + foto punto C
- [ ] Scripts (a) y (b) terminados de probar en VMs (sin finalizar por corte de red)
- [ ] Informe completo (llenar pendientes con la evidencia)
- [ ] Video grabado
- [ ] Commit/push de la rama lab03 a GitHub