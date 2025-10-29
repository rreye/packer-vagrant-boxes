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

# Run clean/autoclean/purge/update first, this will work around problems with ghost packages, and/or
# conflicting data in the repo index cache. After the cleanup is complete, we can proceed with the 
# update/upgrade/install commands below.
apt-get --assume-yes clean ; error
apt-get --assume-yes autoclean ; error
apt-get --assume-yes update ; error

# Upgrade the installed packages.
retry apt-get --assume-yes -o Dpkg::Options::="--force-confnew" upgrade ; error
apt-get --assume-yes -o Dpkg::Options::="--force-confnew" upgrade ; error

# Needed to retrieve source code, and other misc system tools.
apt-get --assume-yes install vim vim-nox git wget curl rsync gnupg mlocate sudo sysstat lsof pciutils usbutils lsb-release psmisc ; error
