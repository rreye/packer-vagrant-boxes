#!/bin/bash -eux

echo "==> Running provision script (Debian)..."

# To allow for automated installs, we disable interactive configuration steps.
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

PACKAGES="vim nano git curl wget tree net-tools openssh-server rsync unzip sudo gnupg locales"

. /etc/os-release
CODENAME=$VERSION_CODENAME
COMPONENTS="main contrib non-free non-free-firmware"

echo "    Configuring repositories (Auto-detection Offline/Online)..."
echo "    Debian Codename: ${CODENAME}"

if mount /dev/cdrom /media/cdrom 2>/dev/null || mount /dev/sr0 /media/cdrom 2>/dev/null; then
    echo "    [OFFLINE] -> CD-ROM detected and mounted."
    echo "    [LSBLK]:"
    lsblk
    apt-cdrom -m -d /media/cdrom add
    echo "    Installing packages..."
    apt-get install -y $PACKAGES

    echo "deb http://deb.debian.org/debian/ ${CODENAME} ${COMPONENTS}" >> /etc/apt/sources.list
    apt-get update -y 2>/dev/null || true
else
    echo "    [ONLINE] -> No CD-ROM. Configuring internet repositories..."
    
    cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ ${CODENAME} ${COMPONENTS}
deb http://security.debian.org/debian-security ${CODENAME}-security ${COMPONENTS}
deb http://deb.debian.org/debian/ ${CODENAME}-updates ${COMPONENTS}
EOF

    apt-get clean
    apt-get update -y
    echo "    Installing packages..."
    apt-get install -y $PACKAGES
fi


sed -i 's/^# *es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
update-locale LANG=es_ES.UTF-8
if [ -f /bin/bash ]; then
    HOME_DIR=/home/vagrant
    echo 'export LC_ALL=es_ES.UTF-8' >> $HOME_DIR/.bashrc
    echo 'export LANG=es_ES.UTF-8' >> $HOME_DIR/.bashrc
    echo 'export LANGUAGE=es_ES.UTF-8' >> $HOME_DIR/.bashrc
fi

echo "    Disabling systemd apt timers/services."
systemctl stop apt-daily.timer
systemctl stop apt-daily-upgrade.timer
systemctl disable apt-daily.timer
systemctl disable apt-daily-upgrade.timer
systemctl mask apt-daily.service
systemctl mask apt-daily-upgrade.service
systemctl daemon-reload

echo "==> Provisioning complete."
