#!/bin/bash -eux

echo "==> Running cleanup script (Ubuntu)..."

# To allow for automated installs, we disable interactive configuration steps.
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Clean apt cache
apt-get autoremove -y
apt-get clean -y

# Remove temporary files
rm -rf /tmp/*

# Remove machine-id to force regeneration on first boot
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Clear bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

# Remove the random seed so a unique value is used the first time the box is booted.
systemctl --quiet is-active systemd-random-seed.service && systemctl stop systemd-random-seed.service
[ -f /var/lib/systemd/random-seed ] && rm --force /var/lib/systemd/random-seed

echo "==> Cleanup complete."
