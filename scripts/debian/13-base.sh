#!/bin/bash -eux

echo "==> Running provision script (Debian)..."

# To allow for automated installs, we disable interactive configuration steps.
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Update packages
apt-get clean
apt-get update
apt-get upgrade -y

# Install common tools
apt-get install -y vim nano git curl wget tree net-tools openssh-server rsync unzip sudo gnupg locales

sed -i 's/^# *es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
update-locale LANG=es_ES.UTF-8

echo "==> Provisioning complete."
