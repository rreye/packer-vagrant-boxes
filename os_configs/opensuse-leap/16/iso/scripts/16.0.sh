#!/bin/bash -eux

echo "==> Running provision script (OpenSuse Leap 16.0)..."

RELEASEVER=16.0
ZYPP_CONF_DIR="/etc/zypp/zypp.conf.d"

mkdir -p "$ZYPP_CONF_DIR"
echo "releasever = ${RELEASEVER}" > "${ZYPP_CONF_DIR}/99-releasever.conf"
echo "Zypper version frozen: ${RELEASEVER} (via 99-releasever.conf)"

DUPLICATE_REPO=$(zypper lr | grep "distribution/leap/${RELEASEVER}/repo/oss" | grep -v "openSUSE:repo-oss" | awk -F '|' '{print $2}' | tr -d ' ')

if [ -n "$DUPLICATE_REPO" ]; then
    echo "Removing duplicated repo: $DUPLICATE_REPO"
    zypper rr "$DUPLICATE_REPO"
fi

# Limpieza de Leap 15 (Instalador AutoYaST - Repo CD/DVD local)
if zypper lr | grep -q "openSUSE-${RELEASEVER}-0"; then
    echo "Removing local DVD/ISO repo (YaST)..."
    zypper rr "openSUSE-${RELEASEVER}-0"
fi

# Refrescar metadatos aplicando el bloqueo de versión
zypper clean --all
zypper refresh

echo "==> Provisioning complete."
