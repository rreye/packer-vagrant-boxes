#!/bin/bash -eux

echo "==> Running provision script (Ubuntu)..."

# To allow for automated installs, we disable interactive configuration steps.
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Update packages
apt-get clean
apt-get update
apt-get upgrade -y

# Install common tools
apt-get install -y vim nano git curl wget tree net-tools openssh-server rynsc unzip sudo gnupg

echo "==> Provisioning complete."
