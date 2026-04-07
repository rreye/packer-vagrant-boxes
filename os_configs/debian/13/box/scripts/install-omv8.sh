#!/bin/bash -eux

export LANG=C.UTF-8
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true
export APT_LISTCHANGES_FRONTEND=none
OMV_VERSION="8"
OMV_VERSION_CODENAME="synchrony"

# Set hostname
hostnamectl set-hostname omv-server

# Disable the Debian backport repositories.
sed -i '/-backports/s/^/#/' /etc/apt/sources.list

# Append user 'vagrant' to group 'ssh', otherwise the user is not allowed
# to log in via SSH.
usermod --groups _ssh --append vagrant

# Install the OMV keyring manually
apt-get install --yes gnupg
wget --quiet --output-document=- https://packages.openmediavault.org/public/archive.key | \
	gpg --dearmor --yes --output "/usr/share/keyrings/openmediavault-archive-keyring.gpg"

# Configure repo and install OMV
cat <<EOF > /etc/apt/sources.list.d/openmediavault.list
deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] http://packages.openmediavault.org/public ${OMV_VERSION_CODENAME} main
EOF

echo "==> Installing openmediavault (${OMV_VERSION_CODENAME}) ..."
apt-get update
apt-get --yes --auto-remove --show-upgraded \
	--allow-downgrades --allow-change-held-packages \
	--no-install-recommends \
	--option DPkg::Options::="--force-confdef" \
	--option DPkg::Options::="--force-confold" \
	install openmediavault

