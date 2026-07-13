#!/bin/bash -eux

echo "==> Running provision script (OpenSuse Leap 15.6)..."

RELEASEVER=15.6
ZYPP_CONF_DIR="/etc/zypp/zypp.conf.d"

mkdir -p "$ZYPP_CONF_DIR"
echo "releasever = ${RELEASEVER}" > "${ZYPP_CONF_DIR}/99-releasever.conf"
echo "Zypper version frozen: ${RELEASEVER} (via 99-releasever.conf)"

# Limpieza de Leap 15 (Instalador AutoYaST - Repo CD/DVD local)
for repo in "openSUSE-Leap-${RELEASEVER}-1" "openSUSE-Leap-${RELEASEVER}-0" "openSUSE-${RELEASEVER}-0"; do
    if zypper lr | grep -q "$repo"; then
        echo "Removing local DVD/ISO repo: $repo"
        zypper rr "$repo" || true
    fi
done

# Inyectar los repositorios OSS principales obligatorios
# Usamos \$releasever escapado para que Zypper use dinámicamente el valor congelado del conf
zypper ar -fc "http://download.opensuse.org/distribution/leap/\$releasever/repo/oss/" repo-oss || true
zypper ar -fc "http://download.opensuse.org/update/leap/\$releasever/oss/" repo-update || true

# Aseguramos que están habilitados por si ya existían pero estaban apagados
zypper mr -e repo-oss || true
zypper mr -e repo-update || true

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
