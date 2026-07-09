#!/bin/bash -eux

echo "==> Running provision script (Rocky 9)..."

# Install common tools (some might be installed by Kickstart already)
dnf clean all
dnf install -y vim nano git curl wget tree net-tools openssh-server rsync tar unzip sudo gnupg2 langpacks-es glibc-locale-source

localedef -i es_ES -f UTF-8 es_ES.UTF-8
localectl set-locale LANG=es_ES.UTF-8
if [ -f /bin/bash ]; then
    HOME_DIR=/home/vagrant
    echo 'export LC_ALL=es_ES.UTF-8' >> $HOME_DIR/.bashrc
    echo 'export LANG=es_ES.UTF-8' >> $HOME_DIR/.bashrc
    echo 'export LANGUAGE=es_ES.UTF-8' >> $HOME_DIR/.bashrc
fi

# Optional: Enable EPEL repository for more packages
dnf install -y epel-release

echo "remove the install log"
rm -f /root/anaconda-ks.cfg /root/original-ks.cfg

SELINUX_STATUS=$(getenforce)
echo "SELinux status: $SELINUX_STATUS"

if [ "$SELINUX_STATUS" != "Disabled" ]; then
  echo "Disabling SELinux..."
  setenforce 0
  CONFIG_FILE="/etc/selinux/config"
    
  if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
    sed -i 's/^SELINUX=.*$/SELINUX=disabled/' "$CONFIG_FILE"
    grubby --update-kernel ALL --args selinux=0
  else
    echo "ERROR: SELinux config file not found at $CONFIG_FILE"
    exit 1
  fi
fi

echo "==> Provisioning complete."
