#!/bin/sh -eux

echo "==> Running guest qemu tools script..."

PKGS="qemu-guest-agent"
BUILDER="${PACKER_BUILDER_TYPE:-qemu}"
if [ "$BUILDER" = "utm-iso" ] || [ "$BUILDER" = "utm" ]; then
  echo "==> [UTM] Adding SPICE tools for UTM..."
  PKGS="$PKGS spice-vdagent spice-webdavd"
fi

if [ -f "/usr/bin/dnf" ]; then
  dnf install --skip-broken -y $PKGS
  sed -i 's/^BLACKLIST_RPC=/# BLACKLIST_RPC=/' /etc/sysconfig/qemu-ga # RHEL 8
  sed -i 's/^FILTER_RPC_ARGS=/# FILTER_RPC_ARGS=/' /etc/sysconfig/qemu-ga # RHEL 9+
elif [ -f "/usr/bin/apt-get" ]; then
  export DEBIAN_FRONTEND=noninteractive
  export DEBCONF_NONINTERACTIVE_SEEN=true
  apt-get install -y $PKGS
elif [ -f "/usr/bin/zypper" ]; then
  zypper install -y $PKGS
elif [ -f "/sbin/apk" ]; then
  apk add --no-cache $PKGS
fi

# Do not start the service during build (virtio not available)
if command -v systemctl >/dev/null 2>&1; then
  # QEMU Guest Agent
  systemctl enable qemu-guest-agent || true
  systemctl stop qemu-guest-agent || true
  
  # SPICE Tools
  if echo "$PKGS" | grep -q "spice-vdagent"; then
    systemctl enable spice-vdagentd || true
    systemctl stop spice-vdagentd || true
    systemctl enable spice-webdavd || true
    systemctl stop spice-webdavd || true
  fi
elif [ -f "/sbin/apk" ]; then
  # Service management in OpenRC (Alpine)
  rc-update add qemu-guest-agent default || true
  rc-service qemu-guest-agent stop || true
  
  if echo "$PKGS" | grep -q "spice-vdagent"; then
    rc-update add spice-vdagentd default || true
    rc-service spice-vdagentd stop || true
    rc-update add spice-webdavd default || true
    rc-service spice-webdavd stop || true
  fi
fi

echo "==> Guest qemu tools complete."
