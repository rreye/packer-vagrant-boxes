#!/bin/sh -eux

echo "==> Running guest vmware tools script..."

if [ -f "/usr/bin/dnf" ]; then
  dnf update
  dnf install -y open-vm-tools
  systemctl enable vmtoolsd
  systemctl start vmtoolsd
elif [ -f "/usr/bin/apt-get" ]; then
  apt-get update
  apt-get install -y open-vm-tools;
  systemctl enable open-vm-tools
  systemctl start open-vm-tools
elif [ -f "/usr/bin/zypper" ]; then
  zypper refresh
  zypper install -y open-vm-tools
  systemctl enable vmtoolsd
  systemctl start vmtoolsd
elif [ -f "/sbin/apk" ]; then
  apk update
  apk add open-vm-tools open-vm-tools-guestinfo
  rc-update add open-vm-tools default
  rc-service open-vm-tools start 
fi

echo "==> Guest vmware tools complete."
