#!/bin/bash -eux

echo "==> Waiting for apt/dpkg..."
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
	sleep 10
done

echo "==> Populating the database..."
# Populate the database.
omv-confdbadm populate

# Deploy the /etc/hosts file to ensure the hostname can be resolved
# properly for IPv4 and IPv6. Otherwise building the Salt grains
# (core.fqdns and core.ip_fqdn) will take a very long time.
omv-salt deploy run hosts

# Display the login information.
cat /etc/issue

omv-salt deploy run monit

echo "==> Installation complete"
