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
apt-get install -y vim nano git curl wget tree net-tools openssh-server rsync unzip sudo gnupg language-pack-es

update-locale LANG=es_ES.UTF-8

systemctl stop apt-daily.timer
systemctl stop apt-daily-upgrade.timer
systemctl disable apt-daily.timer
systemctl disable apt-daily-upgrade.timer
systemctl mask apt-daily.service
systemctl mask apt-daily-upgrade.service
systemctl daemon-reload

rm -rf /var/log/unattended-upgrades
apt-get -y purge unattended-upgrades ubuntu-release-upgrader-core popularity-contest installation-report || true;
apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6 || true;

echo "==> Provisioning complete."
