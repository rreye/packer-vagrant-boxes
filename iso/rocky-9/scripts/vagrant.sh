#!/bin/bash -eux

echo "==> Configuring Vagrant user..."

# User and SSH key are created/installed during Kickstart %post
# Ensure sudo is configured correctly
echo "%wheel ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

passwd -d vagrant
echo 'vagrant:vagrant' | chpasswd -m
passwd -d root
echo 'root:vagrant' | chpasswd -m

# Ensure SSH key permissions
chmod 0700 /home/vagrant/.ssh
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

echo "==> Vagrant configuration complete."
