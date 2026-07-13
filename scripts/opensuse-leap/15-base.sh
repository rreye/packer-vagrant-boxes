#!/bin/bash -eux

echo "==> Running provision script (OpenSuse Leap 15)..."

# Install common tools
zypper clean --all
zypper refresh
zypper install -y vim nano git curl wget tree net-tools openssh rsync tar unzip sudo gpg2 glibc-locale glibc-i18ndata

localedef -i es_ES -f UTF-8 es_ES.UTF-8
localectl set-locale LANG=es_ES.UTF-8
if [ -f /bin/bash ]; then
    HOME_DIR=/home/vagrant
    echo 'export LC_ALL=es_ES.UTF-8' >> $HOME_DIR/.bashrc
    echo 'export LANG=es_ES.UTF-8' >> $HOME_DIR/.bashrc
    echo 'export LANGUAGE=es_ES.UTF-8' >> $HOME_DIR/.bashrc
fi

rm -f /usr/lib/motd.d/welcome
rm -f /root/autoinst.xml
# Limpiar los logs de instalación del sistema
rm -rf /var/log/YaST2/*

echo "==> Provisioning complete."
