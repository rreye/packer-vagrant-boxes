#!/bin/bash -x

error() {
        if [ $? -ne 0 ]; then
                printf "\n\nAPT failed... again.\n\n";
                exit 1
        fi
}

# To allow for automated installs, we disable interactive configuration steps.
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

passwd -d root
echo 'root:vagrant' | chpasswd -m
passwd -d vagrant
echo 'vagrant:vagrant' | chpasswd -m

# SSH config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config
sed -i 's/KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#KbdInteractiveAuthentication/KbdInteractiveAuthentication/' /etc/ssh/sshd_config
systemctl restart ssh

# Run clean/autoclean/purge/update first, this will work around problems with ghost packages, and/or
# conflicting data in the repo index cache. After the cleanup is complete, we can proceed with the 
# update/upgrade/install commands below.
apt-get --assume-yes clean ; error
apt-get --assume-yes autoclean ; error
apt-get --assume-yes update ; error

# Upgrade the installed packages.
apt-get --assume-yes -o Dpkg::Options::="--force-confnew" upgrade ; error
apt-get --assume-yes -o Dpkg::Options::="--force-confnew" upgrade ; error

# Needed to retrieve source code, and other misc system tools.
SOFTWARE="vim vim-nox nano openssh-server git wget curl rsync sshpass unzip dnsutils dos2unix whois gnupg sudo sysstat lsof pciutils usbutils lsb-release psmisc"
echo "==> Installing software packages..."
apt-get --assume-yes install $SOFTWARE ; error
echo "==> done"

