#!/bin/sh -eux

echo "==> Configuring Vagrant user..."

echo "==> Privilege escalation (sudo/doas)"

CONFIGURED=0

# --- doas ---
if command -v doas > /dev/null 2>&1 || [ -d /etc/doas.d ]; then
    echo "  ==> 'doas' environment detected. Configuring /etc/doas.d/vagrant.conf..."    
    mkdir -p /etc/doas.d    
    echo "permit nopass vagrant as root" > /etc/doas.d/vagrant.conf
    chmod 0644 /etc/doas.d/vagrant.conf
    chown root:root /etc/doas.d/vagrant.conf
    CONFIGURED=1
fi

# --- sudo ---
if command -v sudo > /dev/null 2>&1 || [ -d /etc/sudoers.d ]; then
    echo "  ==> 'sudo' environment detected. Configuring /etc/sudoers.d/vagrant..."
    
    mkdir -p /etc/sudoers.d    
    echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant
    chmod 0640 /etc/sudoers.d/vagrant
    chown root:root /etc/sudoers.d/vagrant
    CONFIGURED=1
fi

# --- Verificación ---
if [ "$CONFIGURED" -eq 0 ]; then
    echo "ERROR: Neither 'sudo' nor 'doas' environments were detected on this system."
    exit 1
fi

# Default passwords
passwd -d vagrant
echo 'vagrant:vagrant' | chpasswd
passwd -d root
echo 'root:vagrant' | chpasswd

# Install Vagrant SSH key
HOME_DIR=/home/vagrant
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
