#!/bin/bash
set -e

echo "=== Slackware 15.0 Automated Installation (32-bit) ==="

if [ -f /mnt/etc/passwd ]; then
  echo "System already installed, skipping."
  exit 0
fi

echo "=== Partitioning disk ==="
fdisk /dev/sda <<EOF
o
n
p
1

+100M
a
1
n
p
2

+2G
t
2
82
n
p
3


w
EOF

echo "=== Formatting partitions ==="
mkfs.ext4 -F /dev/sda1
mkswap /dev/sda2
mkfs.ext4 -F /dev/sda3

echo "=== Mounting filesystems ==="
swapon /dev/sda2
mount /dev/sda3 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot

echo "=== Mounting ISO for packages ==="
mkdir -p /mnt/tmpmount
mount /dev/sr0 /mnt/tmpmount

echo "=== Installing packages ==="
for series in a ap d l n; do
  pkgdir="/mnt/tmpmount/slackware/$series"
  count=$(ls "$pkgdir"/*.txz 2>/dev/null | wc -l)
  echo "--- Series $series ($count packages) ---"
  installpkg "$pkgdir"/*.txz
done

echo "=== Configuring installed system ==="
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys

cat > /mnt/etc/fstab <<'FSTAB'
/dev/sda3   /         ext4   defaults   1  1
/dev/sda1   /boot     ext4   defaults   1  2
/dev/sda2   swap      swap   defaults   0  0
FSTAB

cat > /mnt/etc/lilo.conf <<'LILO'
boot = /dev/sda

image = /boot/vmlinuz
  root = /dev/sda3
  label = Slackware
  read-only
LILO

chroot /mnt /sbin/lilo

cat > /mnt/etc/rc.d/rc.inet1.conf <<'NET'
IFNAME[0]="eth0"
IPADDR[0]=""
NETMASK[0]=""
USE_DHCP[0]="yes"
DHCP_HOSTNAME[0]="slackware"
NET

echo "slackware" > /mnt/etc/HOSTNAME
sed -i '1s/127.0.0.1\s.*/127.0.0.1\tslackware.localdomain\tslackware/' /mnt/etc/hosts

echo "root:vagrant" | chroot /mnt chpasswd

chroot /mnt useradd -m vagrant
echo "vagrant:vagrant" | chroot /mnt chpasswd
chroot /mnt usermod -aG wheel vagrant

chroot /mnt mkdir -p /etc/sudoers.d
echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /mnt/etc/sudoers.d/vagrant
chmod 440 /mnt/etc/sudoers.d/vagrant

chroot /mnt chmod +x /etc/rc.d/rc.sshd

mkdir -p /mnt/home/vagrant/.ssh
cat > /mnt/home/vagrant/.ssh/authorized_keys <<'KEY'
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
KEY
chroot /mnt chown -R vagrant:vagrant /home/vagrant/.ssh
chroot /mnt chmod 700 /home/vagrant/.ssh
chroot /mnt chmod 600 /home/vagrant/.ssh/authorized_keys

echo "=== Cleaning up ==="
sync
umount -R /mnt
swapoff /dev/sda2

echo "=== Installation complete, rebooting ==="
reboot -f
