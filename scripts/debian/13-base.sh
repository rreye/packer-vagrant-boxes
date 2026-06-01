#!/bin/bash -eux

echo "==> Running provision script (Debian 13)..."

# To allow for automated installs, we disable interactive configuration steps.
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Install common tools
apt-get clean
apt-get update -y
apt-get install -y vim nano git curl wget tree net-tools openssh-server rsync unzip sudo gnupg locales

sed -i 's/^# *es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/XKBLAYOUT=".*"/XKBLAYOUT="es"/' /etc/default/keyboard
locale-gen
update-locale LANG=es_ES.UTF-8
if [ -f /bin/bash ]; then
    HOME_DIR=/home/vagrant
    echo 'export LC_ALL=es_ES.UTF-8' >> $HOME_DIR/.bashrc
    echo 'export LANG=es_ES.UTF-8' >> $HOME_DIR/.bashrc
    echo 'export LANGUAGE=es_ES.UTF-8' >> $HOME_DIR/.bashrc
fi

echo "disable systemd apt timers/services"
systemctl stop apt-daily.timer
systemctl stop apt-daily-upgrade.timer
systemctl disable apt-daily.timer
systemctl disable apt-daily-upgrade.timer
systemctl mask apt-daily.service
systemctl mask apt-daily-upgrade.service
systemctl daemon-reload

echo "==> Provisioning complete."
