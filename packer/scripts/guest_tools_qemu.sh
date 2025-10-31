#!/bin/sh -eux

echo "==> Running guest qemu tools script..."

if [ -f "/bin/dnf" ]; then
  dnf install -y --skip-broken qemu-guest-agent
  sed -i 's/^BLACKLIST_RPC=/# BLACKLIST_RPC=/' /etc/sysconfig/qemu-ga # RHEL 8 instances
  sed -i 's/^FILTER_RPC_ARGS=/# FILTER_RPC_ARGS=/' /etc/sysconfig/qemu-ga # RHEL 9+ instances
elif [ -f "/usr/bin/apt-get" ]; then
  apt-get update
  apt-get install -y qemu-guest-agent
elif [ -f "/usr/bin/zypper" ]; then
  zypper install -y qemu-guest-agent
fi

systemctl enable qemu-guest-agent
systemctl start qemu-guest-agent
  
echo "==> Guest qemu tools complete."
