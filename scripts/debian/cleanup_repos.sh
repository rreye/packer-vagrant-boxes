#!/bin/bash -eux

echo "==> Running cleanup script (Debian)..."

umount /media/cdrom 2>/dev/null || true
. /etc/os-release
CODENAME=$VERSION_CODENAME

echo "    Debian Codename: ${CODENAME}"

COMPONENTS="main contrib non-free"
if [ "$CODENAME" = "bookworm" ] || [ "$CODENAME" = "trixie" ]; then
    COMPONENTS="main contrib non-free non-free-firmware"
fi

# Sobrescribir el sources.list inyectando las variables
cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ ${CODENAME} ${COMPONENTS}
deb http://security.debian.org/debian-security ${CODENAME}-security ${COMPONENTS}
deb http://deb.debian.org/debian/ ${CODENAME}-updates ${COMPONENTS}
EOF

rm /etc/apt/sources.list.d/snapshot.list 2>/dev/null || true
rm /etc/apt/apt.conf.d/99snapshot 2>/dev/null || true
apt-get clean
apt-get update -y
apt-get clean

echo "==> Cleanup complete."
