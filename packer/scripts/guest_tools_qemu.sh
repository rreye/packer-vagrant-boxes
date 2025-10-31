#!/bin/sh -eux

echo "==> Running guest qemu tools script..."

if [ -f "/usr/bin/dnf" ]; then
  dnf update
  dnf install -y --skip-broken qemu-guest-agent
  sed -i 's/^BLACKLIST_RPC=/# BLACKLIST_RPC=/' /etc/sysconfig/qemu-ga # RHEL 8 instances
  sed -i 's/^FILTER_RPC_ARGS=/# FILTER_RPC_ARGS=/' /etc/sysconfig/qemu-ga # RHEL 9+ instances
  systemctl enable qemu-guest-agent
  systemctl start qemu-guest-agent
elif [ -f "/usr/bin/apt-get" ]; then
  apt-get update
  apt-get install -y qemu-guest-agent
  systemctl enable qemu-guest-agent
  systemctl start qemu-guest-agent
elif [ -f "/usr/bin/zypper" ]; then
  zypper refresh
  zypper install -y qemu-guest-agent
  systemctl enable qemu-guest-agent
  systemctl start qemu-guest-agent
elif [ -f "/sbin/apk" ]; then
  apk update
  apk add --no-cache qemu-guest-agent
  rc-update add qemu-guest-agent default
  rc-service qemu-guest-agent start
fi
  
echo "==> Guest qemu tools complete."
