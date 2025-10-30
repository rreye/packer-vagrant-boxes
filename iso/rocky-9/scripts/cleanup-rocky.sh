#!/bin/bash -eux

echo "==> Running cleanup script (Rocky)..."

# Clean dnf cache
dnf clean all

# Remove temporary files
rm -rf /tmp/*
rm -f /var/log/wtmp /var/log/btmp # Clear login records

# Remove machine-id
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Clear bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

echo "==> Cleanup complete."
