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
  echo "Alpine detected. Using 'rc-service sshd'."
  rc-service sshd restart
elif command -v systemctl > /dev/null 2>&1; then
  echo "Systemd detected. Checking for 'ssh.service' vs 'sshd.service'..."
  if systemctl list-unit-files --type=service | grep -q '^ssh.service'; then
        # Debian/Ubuntu
        echo "Found 'ssh.service' (Debian/Ubuntu style)."
        systemctl restart ssh
    else
        echo "Did not find 'ssh.service', using 'sshd.service' (RHEL/SUSE style)."
        systemctl restart sshd
    fi
else
    echo "CRITICAL ERROR: Cannot determine init system (not OpenRC or Systemd)."
    exit 1
fi

echo "==> SSHD configuration complete."
