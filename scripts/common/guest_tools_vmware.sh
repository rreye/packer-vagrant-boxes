#!/bin/sh -eux

echo "==> Running guest vmware tools script..."

if [ -f "/usr/bin/dnf" ]; then
  dnf install -y open-vm-tools
  systemctl enable vmtoolsd
  systemctl start vmtoolsd
elif [ -f "/usr/bin/apt-get" ]; then
  export DEBIAN_FRONTEND=noninteractive
  export DEBCONF_NONINTERACTIVE_SEEN=true
  apt-get update -y
  apt-get install -y open-vm-tools
  systemctl enable open-vm-tools
  systemctl start open-vm-tools
elif [ -f "/usr/bin/zypper" ]; then
  zypper refresh -y
  zypper install -y open-vm-tools
  systemctl enable vmtoolsd
  systemctl start vmtoolsd
elif [ -f "/sbin/apk" ]; then
  apk update
  apk add --no-cache open-vm-tools open-vm-tools-guestinfo
  rc-update add open-vm-tools default
  rc-service open-vm-tools start 
fi

echo "==> Guest vmware tools complete."
