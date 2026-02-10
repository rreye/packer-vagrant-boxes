#!/bin/sh -eux

echo "==> Configuring Vagrant user..."

HOME_DIR=/home/vagrant

if [ -f /etc/alpine-release ]; then
    # --- Alpine (doas) ---
    echo "==> Detected Alpine. Configuring doas..."
    
    if ! command -v doas > /dev/null 2>&1; then
        echo "ERROR: 'doas' command not found."
        echo "Please ensure 'doas' is installed in your OS provision.sh (e.g., 'apk add doas')"
        exit 1
    fi
    
    # "permit nopass vagrant" permite al usuario vagrant ejecutar todo como root sin pass.
    echo "permit nopass vagrant" > /etc/doas.conf
    chmod 0400 /etc/doas.conf
    chown root:root /etc/doas.conf
else
    # --- Sudo (Debian, Ubuntu, RHEL, SUSE) ---
    echo "==> Detected sudo-based system. Configuring /etc/sudoers.d/vagrant..."
    
    if [ ! -d /etc/sudoers.d/ ]; then
        echo "ERROR: /etc/sudoers.d/ directory not found."
        echo "Please ensure 'sudo' is installed."
        exit 1
    fi
    
    echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant
    chmod 0440 /etc/sudoers.d/vagrant
fi

# Default passwords
passwd -d vagrant
echo 'vagrant:vagrant' | chpasswd
passwd -d root
echo 'root:vagrant' | chpasswd

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
chown -R vagrant: $HOME_DIR/.ssh

# Set vagrant user's shell to bash (if installed)
if [ -f /bin/bash ]; then
  if command -v chsh > /dev/null 2>&1; then
    chsh -s /bin/bash vagrant
  fi
fi

echo "==> Vagrant user configuration complete."
