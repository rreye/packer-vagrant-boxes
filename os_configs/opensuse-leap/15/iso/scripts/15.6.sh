#!/bin/bash -eux

echo "==> Running provision script (OpenSuse Leap 15.6)..."

RELEASEVER=15.6
ZYPP_CONF_DIR="/etc/zypp/zypp.conf.d"

mkdir -p "$ZYPP_CONF_DIR"
echo "releasever = ${RELEASEVER}" > "${ZYPP_CONF_DIR}/99-releasever.conf"
echo "Zypper version frozen: ${RELEASEVER} (via 99-releasever.conf)"

# Inyectar los repositorios OSS principales obligatorios
# Usamos \$releasever escapado para que Zypper use dinámicamente el valor congelado del conf
zypper ar -fc "http://download.opensuse.org/distribution/leap/\$releasever/repo/oss/" repo-oss || true
zypper ar -fc "http://download.opensuse.org/update/leap/\$releasever/oss/" repo-update || true

# Aseguramos que están habilitados por si ya existían pero estaban apagados
zypper mr -e repo-oss || true
zypper mr -e repo-update || true

echo "==> Provisioning complete."
