# Lab 6 AYSR: Application Layer Protocols, Base Platform, and Network Layer

Feature: lab06-completo. Branch: `feat/lab06`. Created 2026-10-03.
Source guide: `C:\Users\camil\.claude\uploads\4d4e63f6-73dd-4fdd-a1da-891f8bd72caf\308f475f-Laboratory_No.06.pdf`.
Group: 2 students (Camilo Aguirre Rico, Juan David Rangel). Professor: John Alexander Pachón Pinzón.

## Objective
Do the whole Lab 6 literally as the guide says (user rule: "al pie de la letra", real evidence only, full absolute paths, no own decisions), prepare a Word report and a "what to do in the university" guide, and consolidate everything in `D:\LAB 6\` when disk D is available.

## Constraints
- Disk D (with all VMs) is physically with the user at the university. VM-dependent tasks are PREPARED now (configs and scripts) and EXECUTED when D is back.
- Everything lives in `D:\LAB 6\` (moved on 2026-10-05).
- Never type user passwords; the user logs in to cloud services. Do not touch EC2 `camilo-server`.
- Decision (user, 2026-10-03): point 2.1.a gets a REAL FreeBSD VM (literal reading of the guide), not Solaris.
- Assumptions to confirm: Student 01 = Juan, Student 02 = Camilo (as in Lab 3); IOS passwords literally `ClaveE`/`ClaveC`/`ClaveT`; grade scale 0.0 to 5.0.
- TDD: not enabled (no project config). Ordinary functional checks per task. Runner: Python scripts in the repo.

## Tasks
- [x] T1 Router simulation (guide point 1): addressing plan, IOS configs for both setups, reachability verifier. Route: inline (Python generator). Commit 8f9d512. Evidence: `routers/salida/verificacion.txt` (simulation: 2 of 6 PC pairs reachable without routes, 6 of 6 with static routes, both setups). Pending: real ping/tracert inside Packet Tracer, run by the user.
- [x] T2 PHP grade calculator + PostgreSQL schema (guide point 3). Route: inline. Files in `webapp/`. Verified on the FreeBSD VM (Apache 2.4 + PHP 8.3.33 + temporary PostgreSQL 16): CLI logic test 16/16 OK; HTTP form tests from the host OK (4.10 passes, 2.50 fails, invalid grades rejected, script tag escaped); rows read back from PostgreSQL. Evidence: `evidencias/freebsd-webapp-prueba.txt`, `evidencias/freebsd-php-instalacion.txt`. Pending for the final deployment: point `config.php` to the Lab 5 PostgreSQL (Slackware) instead of the temporary one, when D is connected.
- [~] T3 DNS for Lab 6 on the existing BIND of Lab 3 (guide 2.1.g and 2.2.b). `dns/generar_zonas.py` writes zones, named.conf additions and web names for modes uni and casa. Written, not applied: needs the VMs (D).
- [~] T4 Web servers (guide 2.1): install scripts for FreeBSD Apache, Slackware Nginx (source build) and Windows IIS; shell and PowerShell syntax checked, not executed. FreeBSD VM DONE and verified: official image 14.5-RELEASE (sha256 matches the official CHECKSUM), VM `freebsd-14.5-lab06` created on C: (to be moved to D with movevm), SSH 127.0.0.1:2226, HTTP 127.0.0.1:8081. Apache 2.4 installed (2.1.a), test page (2.1.d), autostart verified by reboot (2.1.e), access from the host PC (2.1.f). Evidence: `evidencias/freebsd-apache-instalacion.txt`, `evidencias/freebsd-apache-pruebas.txt`. Nginx (Slackware) and IIS (Windows) still pending: they need the VMs on D.
- [~] T5 Hosting service (guide 2.2): `hosting/solaris/instalar.sh` with two vhosts (network.juan.com.co, security.camilo.org.jp). Open: third domain for a group of 2. Not executed (needs Solaris on D).
- [x] T6 (2026-10-03, evidencia en evidencias/) Execute T2 to T5 on the VMs when D is connected; collect real evidence.
- [x] T7 (informe/Laboratorio06-AYSR.docx/.pdf y QUE HACES EN LA U (Lab 6)) Word report and "QUE HACES EN LA U (Lab 6)" guide; consolidate in `D:\LAB 6\`.

- [x] T8 (2026-10-15, user: "acaba el laboratorio por completo, no pares hasta acabarlo") Juan's Packet Tracer setup built by Claude at Camilo's request (Juan is busy), saved to juan/packet-tracer/juan-lab06.pkt.
- [x] T9 Multiuser link between the Camilo and Juan setups through Router1, two local Packet Tracer instances.
- [x] T10 Third site of point 2.2: closed as not applicable (the guide gives it to a Student 03 this two-student group does not have); documented in the report, LEEME and guides.
- [x] T11 Final report, per-person folders and READMEs updated; review script green; everything committed.

## Acceptance
Each task closes only with observed evidence (command output, screenshot or file). Failed, skipped or pending checks are reported honestly.

## Progress and evidence
(updated per task)

## Next step
T1.
