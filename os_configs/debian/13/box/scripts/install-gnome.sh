#!/bin/bash -eux

echo "==> Running provision script (Debian)..."

# To allow for automated installs, we disable interactive configuration steps.
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Update packages
apt-get clean
apt-get update -y
apt-get install -y gnome-core nfs-common cifs-utils smbclient nfs4-acl-tools nautilus-share seahorse-nautilus firefox-esr gvfs-backends filezilla
systemctl set-default graphical.target
apt-get autoremove -y
apt-get clean -y
apt-get autoclean
	
echo "==> Provisioning complete."
