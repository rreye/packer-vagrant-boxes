#!/bin/sh -eux

echo "==> Running provision script (Alpine 3.23)..."

# Install common tools
apk cache clean
apk add --no-cache vim nano git curl wget tree net-tools openssh-server rsync util-linux musl-locales bash

# Enable community repository if needed for more packages
echo "http://dl-cdn.alpinelinux.org/alpine/v3.23/community" >> /etc/apk/repositories
apk update

HOME_DIR=/home/vagrant
if [ -f /bin/bash ]; then
    echo 'export LC_ALL=es_ES.UTF-8' >> $HOME_DIR/.bashrc
    echo 'export LANG=es_ES.UTF-8' >> $HOME_DIR/.bashrc
    echo 'export LANGUAGE=es_ES.UTF-8' >> $HOME_DIR/.bashrc
else
    echo 'export LC_ALL=es_ES.UTF-8' >> $HOME_DIR/.profile
    echo 'export LANG=es_ES.UTF-8' >> $HOME_DIR/.profile
    echo 'export LANGUAGE=es_ES.UTF-8' >> $HOME_DIR/.profile
fi

echo "==> Provisioning complete."
