#!/bin/bash
# setup.sh — Post-install para Solaris 11.4 (Lab 01) — VERSION SOLARIS (POSIX)
# Ejecutar como root. Corrige: sed -i -> perl, /home/admin -> /export/home/admin

set -e
echo "============================================"
echo " Solaris 11.4 — Setup post-instalacion Lab01"
echo "============================================"

# --- 1. Teclado US ---
echo ">>> Teclado US-English..."
kbd -s US-English 2>/dev/null || true

# --- 2. Red (idempotente) ---
echo ">>> Red..."
ipadm show-addr net0/v4 >/dev/null 2>&1 || ipadm create-addr -T static -a local=10.2.78.65/16 net0/v4
ipadm show-addr net0/v4nat >/dev/null 2>&1 || ipadm create-addr -T static -a local=10.0.2.15/24 net0/v4nat
route -p add default 10.2.65.1 2>/dev/null || true
echo "nameserver 10.2.65.1" > /etc/resolv.conf
echo "Red: OK"

# --- 3. SSH: PermitRootLogin (primera directiva gana) ---
echo ">>> SSH..."
perl -pi -e 's/^PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
grep -q '^PermitRootLogin yes' /etc/ssh/sshd_config || echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
svcadm enable ssh 2>/dev/null || true
svcadm restart ssh 2>/dev/null || true

# --- 4. Usuario admin + llave + pfexec ---
echo ">>> Usuario admin..."
id admin >/dev/null 2>&1 || useradd -m -s /usr/bin/bash admin
mkdir -p /export/home/admin/.ssh
cp /root/.ssh/authorized_keys /export/home/admin/.ssh/authorized_keys 2>/dev/null || true
chmod 700 /export/home/admin/.ssh
chmod 600 /export/home/admin/.ssh/authorized_keys
chown admin /export/home/admin/.ssh /export/home/admin/.ssh/authorized_keys

# pfexec All (idempotente: evitar duplicar admin)
perl -pi -e 's/^admin::::.*/admin::::type=role;profiles=All/' /etc/user_attr
grep -q '^admin::::' /etc/user_attr 2>/dev/null || echo 'admin::::type=role;profiles=All' >> /etc/user_attr

# exec_attr: All eleva a root
grep -q '^All:solaris:cmd:::\*:uid=0;gid=0' /etc/security/exec_attr.d/core-os 2>/dev/null \
  || echo 'All:solaris:cmd:::*:uid=0;gid=0' >> /etc/security/exec_attr.d/core-os

echo "admin: OK"

# --- 5. Usuarios del lab ---
echo ">>> Usuarios lab..."
groupadd Accounting 2>/dev/null || true
groupadd IT 2>/dev/null || true
mkdir -p /usuarios

id claudia >/dev/null 2>&1 || useradd -d /usuarios/claudia -m -c "Claudia - usuario con el nombre de la profesora" -g Accounting -s /usr/bin/bash claudia
id john    >/dev/null 2>&1 || useradd -d /usuarios/john    -m -c "John - usuario con el nombre del profesor"     -g Accounting -s /usr/bin/bash john
id fabian  >/dev/null 2>&1 || useradd -d /usuarios/fabian -m -c "Fabian - usuario con el nombre del profesor" -g IT -s /usr/bin/bash fabian
id diego   >/dev/null 2>&1 || useradd -d /usuarios/diego  -m -c "Diego - usuario con el nombre del profesor"  -g IT -s /usr/bin/bash diego

echo "Usuarios: OK"

# --- 6. Scripts guest uni/casa ---
echo ">>> Scripts guest..."
cat > /root/uni.sh << 'UNI_EOF'
#!/bin/bash
# uni.sh — IP estatica 10.2.78.65 (universidad)
echo "=== Uni: IP estatica 10.2.78.65 ==="
ipadm show-addr net0/v4 >/dev/null 2>&1 && ipadm delete-addr net0/v4 2>/dev/null || true
ipadm create-addr -T static -a local=10.2.78.65/16 net0/v4
route -p add default 10.2.65.1 2>/dev/null || true
echo "nameserver 10.2.65.1" > /etc/resolv.conf
hostname solaris
echo "=== Uni: listo ==="
UNI_EOF

cat > /root/casa.sh << 'CASA_EOF'
#!/bin/bash
# casa.sh — DHCP + alias NAT 10.0.2.15 (casa)
echo "=== Casa: DHCP + alias NAT ==="
ipadm delete-addr net0/v4 2>/dev/null || true
ipadm delete-addr net0/v4nat 2>/dev/null || true
ipadm create-addr -T dhcp net0/v4
ipadm create-addr -T static -a local=10.0.2.15/24 net0/v4nat
echo "=== Casa: listo ==="
CASA_EOF

chmod +x /root/uni.sh /root/casa.sh
echo "Scripts: OK"

# --- 7. Verificacion ---
echo ""
echo "============================================"
echo " Setup completo. Verificando..."
echo "============================================"
echo "--- Red ---"
ipadm show-addr
echo "--- Usuarios ---"
id claudia 2>/dev/null && echo "claudia: OK"
id john    2>/dev/null && echo "john: OK"
id fabian  2>/dev/null && echo "fabian: OK"
id diego   2>/dev/null && echo "diego: OK"
echo "--- Homes ---"
ls -la /usuarios/ 2>/dev/null
echo "--- SSH ---"
svcs -l ssh 2>/dev/null | head -5
echo "--- admin pfexec ---"
grep admin /etc/user_attr 2>/dev/null
echo ""
echo "Listo! Falta: asignar passwords (passwd claudia, etc)."
