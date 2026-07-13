#!/bin/bash -eux

echo "==> Running provision script (OpenSuse Leap 16.0)..."

RELEASEVER=16.0
ZYPP_CONF_DIR="/etc/zypp/zypp.conf.d"

mkdir -p "$ZYPP_CONF_DIR"
echo "releasever = ${RELEASEVER}" > "${ZYPP_CONF_DIR}/99-releasever.conf"
echo "Zypper version frozen: ${RELEASEVER} (via 99-releasever.conf)"

# Limpieza de duplicados
# El '|| true' en el grep evita que el script aborte si no hay duplicados
DUPLICATE_REPOS=$(zypper lr | grep "distribution/leap/${RELEASEVER}/repo/oss" | grep -v "repo-oss" | awk -F '|' '{print $2}' | tr -d ' ' || true)

if [ -n "$DUPLICATE_REPOS" ]; then
    for repo in $DUPLICATE_REPOS; do
        echo "Removing duplicated repo: $repo"
        zypper rr "$repo" || true
    done
fi

# Refrescar metadatos aplicando el bloqueo de versión
zypper clean --all
zypper refresh

echo "==> Provisioning complete."
