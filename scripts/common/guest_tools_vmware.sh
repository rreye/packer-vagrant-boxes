#!/bin/sh -eux

echo "==> Running guest vmware tools script..."

if [ -f "/usr/bin/dnf" ]; then
  dnf install -y open-vm-tools
  systemctl enable vmtoolsd
  systemctl start vmtoolsd
elif [ -f "/usr/bin/apt-get" ]; then
  export DEBIAN_FRONTEND=noninteractive
  export DEBCONF_NONINTERACTIVE_SEEN=true
  apt-get install -y open-vm-tools
  systemctl enable open-vm-tools
  systemctl start open-vm-tools
elif [ -f "/usr/bin/zypper" ]; then
  zypper install -y open-vm-tools
  systemctl enable vmtoolsd
  systemctl start vmtoolsd
elif [ -f "/sbin/apk" ]; then
  apk add --no-cache open-vm-tools open-vm-tools-guestinfo open-vm-tools-hgfs fuse acpid
  if ! grep -q "^fuse$" /etc/modules; then
    echo "fuse" >> /etc/modules
  fi
  rc-update add acpid default
  rc-update add open-vm-tools default
  rc-service open-vm-tools start
  rc-service open-vm-tools acpid
fi

echo "==> Guest vmware tools complete."
