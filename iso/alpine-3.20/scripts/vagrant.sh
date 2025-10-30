#!/bin/sh -eux

echo "==> Configuring Vagrant user..."

# User created by answerfile, configure sudo
echo "%wheel ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

passwd -d vagrant
echo 'vagrant:vagrant' | chpasswd -m
passwd -d root
echo 'root:vagrant' | chpasswd -m

# SSH key already added by answerfile, ensure permissions
chmod 0700 /home/vagrant/.ssh
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Set vagrant user's shell to bash (if installed)
if [ -f /bin/bash ]; then
  chsh -s /bin/bash vagrant
fi

echo "==> Vagrant configuration complete."
