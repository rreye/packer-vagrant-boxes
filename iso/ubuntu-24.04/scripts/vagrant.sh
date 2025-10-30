#!/bin/bash -eux

echo "==> Configuring Vagrant user..."

# To allow for automated installs, we disable interactive configuration steps.
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Create vagrant user (already created by autoinstall, ensure settings)
echo "%vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

passwd -d vagrant
echo 'vagrant:vagrant' | chpasswd -m
passwd -d root
echo 'root:vagrant' | chpasswd -m

# Install Vagrant SSH key
mkdir -p /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh
curl -fsSL 'https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub' -o /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

echo "==> Vagrant configuration complete."
