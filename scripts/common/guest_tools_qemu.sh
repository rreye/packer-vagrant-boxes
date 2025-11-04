#!/bin/sh -eux

echo "==> Running guest qemu tools script..."

# Do not start the service during build (virtio not available)
  
if [ -f "/usr/bin/dnf" ]; then
  dnf install -y qemu-guest-agent
  sed -i 's/^BLACKLIST_RPC=/# BLACKLIST_RPC=/' /etc/sysconfig/qemu-ga # RHEL 8 instances
  sed -i 's/^FILTER_RPC_ARGS=/# FILTER_RPC_ARGS=/' /etc/sysconfig/qemu-ga # RHEL 9+ instances
  systemctl stop qemu-guest-agent || true
elif [ -f "/usr/bin/apt-get" ]; then
  export DEBIAN_FRONTEND=noninteractive
  export DEBCONF_NONINTERACTIVE_SEEN=true
  apt-get update -y
  apt-get install -y qemu-guest-agent
  systemctl stop qemu-guest-agent || true
elif [ -f "/usr/bin/zypper" ]; then
  zypper refresh -y
  zypper install -y qemu-guest-agent
  systemctl stop qemu-guest-agent || true
elif [ -f "/sbin/apk" ]; then
  apk update
  apk add --no-cache qemu-guest-agent
  rc-update add qemu-guest-agent default || true
  rc-service qemu-guest-agent stop || true
fi
  
echo "==> Guest qemu tools complete."
