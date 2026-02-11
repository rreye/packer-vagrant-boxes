#!/bin/bash -eux

echo "==> Running provision script (Rocky)..."

# Install common tools (some might be installed by Kickstart already)
dnf clean all
dnf install -y vim nano git curl wget tree net-tools openssh-server rsync unzip sudo gnupg langpacks-es glibc-locale-source

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

echo "==> Provisioning complete."
