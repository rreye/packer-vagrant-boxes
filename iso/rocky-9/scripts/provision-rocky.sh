#!/bin/bash -eux

echo "==> Running provision script (Rocky)..."

# Update packages
dnf update -y

# Install common tools (some might be installed by Kickstart already)
dnf install -y vim nano git curl wget tree net-tools openssh-server rynsc unzip sudo gnupg

# Optional: Enable EPEL repository for more packages
dnf install -y epel-release
dnf update -y

# SSH config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config
sed -i 's/KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#KbdInteractiveAuthentication/KbdInteractiveAuthentication/' /etc/ssh/sshd_config
systemctl restart ssh

echo "==> Provisioning complete."
