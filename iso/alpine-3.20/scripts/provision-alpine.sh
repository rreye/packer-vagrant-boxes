#!/bin/sh -eux

echo "==> Running provision script (Alpine)..."

# Update packages
apk update
apk upgrade

# Install common tools
apk add --no-cache vim nano git curl wget tree net-tools openssh-server rsync unzip sudo gnupg bash

# Enable community repository if needed for more packages
echo "http://dl-cdn.alpinelinux.org/alpine/v3.20/community" >> /etc/apk/repositories
apk update

# SSH config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config
sed -i 's/KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#KbdInteractiveAuthentication/KbdInteractiveAuthentication/' /etc/ssh/sshd_config
systemctl restart ssh

echo "==> Provisioning complete."
