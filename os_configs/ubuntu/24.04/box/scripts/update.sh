#!/bin/bash -eux

echo "==> Running provision script (Ubuntu)..."

# To allow for automated installs, we disable interactive configuration steps.
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Update packages
apt-get clean
apt-get update -y
apt-get dist-upgrade -y
apt-get autoremove -y
apt-get clean -y
apt-get autoclean
	
echo "==> Provisioning complete."
