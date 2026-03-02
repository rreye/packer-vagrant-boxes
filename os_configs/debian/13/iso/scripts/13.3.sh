#!/bin/bash -eux

echo "==> Running provision script (Debian)..."

SNAPSHOT_DATE="20260111T000000Z"
DEB_VERSION=$(cat /etc/debian_version)
echo "==> Debian version $DEB_VERSION"
echo "==> Debian snapshot: ${SNAPSHOT_DATE}..."

. /etc/os-release
CODENAME=$VERSION_CODENAME
COMPONENTS="main contrib non-free non-free-firmware"

echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99snapshot
echo "deb [check-valid-until=no] https://snapshot.debian.org/archive/debian/${SNAPSHOT_DATE}/ ${CODENAME} ${COMPONENTS}" > /etc/apt/sources.list.d/snapshot.list

apt-get clean

echo "==> Provisioning complete."
