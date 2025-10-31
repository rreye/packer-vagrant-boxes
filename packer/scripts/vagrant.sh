#!/bin/sh -eux

echo "==> Configuring Vagrant user..."

HOME_DIR=/home/vagrant

# Sudo config
echo "%vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant
echo "%wheel ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

# Default passwords
passwd -d vagrant
echo 'vagrant:vagrant' | chpasswd -m
passwd -d root
echo 'root:vagrant' | chpasswd -m

# Install Vagrant SSH key
mkdir -p $HOME_DIR/.ssh
pubkey_url="https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub"

if command -v curl > /dev/null 2>&1; then
  curl -fsSL "$pubkey_url" -o $HOME_DIR/.ssh/authorized_keys && \
  echo "Successfully downloaded vagrant public key with curl"
elif command -v wget > /dev/null 2>&1; then
  wget --no-check-certificate "$pubkey_url" -O $HOME_DIR/.ssh/authorized_keys && \
  echo "Successfully downloaded vagrant public key with wget"
else
    echo "Cannot download vagrant public key"
    exit 1
fi

# Set permissions
chmod 0700 $HOME_DIR/.ssh
chmod 0600 $HOME_DIR/.ssh/authorized_keys
chown -R vagrant:vagrant $HOME_DIR/.ssh

# Set vagrant user's shell to bash (if installed)
if [ -f /bin/bash ]; then
  chsh -s /bin/bash vagrant
fi

echo "==> Vagrant user configuration complete."
