#!/bin/bash -eux

echo "==> Running provision script (OpenSuse Leap 15.6)..."

RELEASEVER=15.6
ZYPP_CONF_DIR="/etc/zypp/zypp.conf.d"

mkdir -p "$ZYPP_CONF_DIR"
echo "releasever = ${RELEASEVER}" > "${ZYPP_CONF_DIR}/99-releasever.conf"
echo "Zypper version frozen: ${RELEASEVER} (via 99-releasever.conf)"

echo "==> Provisioning complete."
