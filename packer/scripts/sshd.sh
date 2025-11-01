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

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' $SSHD_CONFIG
sed -i 's/#PasswordAuthentication/PasswordAuthentication/' $SSHD_CONFIG
sed -i 's/KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/' $SSHD_CONFIG
sed -i 's/#KbdInteractiveAuthentication/KbdInteractiveAuthentication/' $SSHD_CONFIG
sed -i 's/UseDNS yes/UseDNS no/' $SSHD_CONFIG
sed -i 's/#UseDNS/UseDNS/' $SSHD_CONFIG

systemctl restart ssh

echo "==> SSHD configuration complete."
