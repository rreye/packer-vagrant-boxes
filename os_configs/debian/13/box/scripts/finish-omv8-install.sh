#!/bin/sh

set -e

echo "Esperando a que apt/dpkg liberen el sistema..."
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
	sleep 5
done

echo "Populating database ..."
# Populate the database.
omv-confdbadm populate

# Deploy the /etc/hosts file to ensure the hostname can be resolved
# properly for IPv4 and IPv6. Otherwise building the Salt grains
# (core.fqdns and core.ip_fqdn) will take a very long time.
omv-salt deploy run hosts

systemctl stop systemd-networkd-wait-online.service
systemctl mask systemd-networkd-wait-online.service
systemctl mask openmediavault-issue.service
	
# Display the login information.
cat /etc/issue
