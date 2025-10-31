#!/bin/sh -eux

echo "==> Running guest vmware tools script..."

if [ -f "/bin/dnf" ]; then
  dnf install -y open-vm-tools
  systemctl enable vmtoolsd
  systemctl start vmtoolsd
elif [ -f "/usr/bin/apt-get" ]; then
  apt-get install -y open-vm-tools;
  mkdir /mnt/hgfs;
  systemctl enable open-vm-tools
  systemctl start open-vm-tools
elif [ -f "/usr/bin/zypper" ]; then
  zypper install -y open-vm-tools
  mkdir /mnt/hgfs
  systemctl enable vmtoolsd
  systemctl start vmtoolsd
fi

echo "==> Guest vmware tools complete."
