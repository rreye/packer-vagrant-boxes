#!/bin/sh -eux

echo "==> Configuring SSHD..."

if [ -f "/etc/ssh/sshd_config" ]; then
  SSHD_CONFIG="/etc/ssh/sshd_config"
elif [ -f "/usr/etc/ssh/sshd_config" ]; then
  SSHD_CONFIG="/usr/etc/ssh/sshd_config"
else
  echo "Unable to find sshd_config"
  exit 1
fi

echo "PermitRootLogin yes" > $SSHD_CONFIG
echo "PasswordAuthentication yes" >> $SSHD_CONFIG
echo "KbdInteractiveAuthentication yes" >> $SSHD_CONFIG
echo "GSSAPIAuthentication no" >> $SSHD_CONFIG
echo "UseDNS no" >> $SSHD_CONFIG

if [ -f /etc/alpine-release ]; then
  rc-service sshd restart
else
  systemctl restart sshd
fi

echo "==> SSHD configuration complete."
