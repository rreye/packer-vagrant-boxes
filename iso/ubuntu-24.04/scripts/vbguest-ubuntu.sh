#!/bin/bash -eux

echo "==> Running Vbox guest addons installation script (Ubuntu)..."

# To allow for automated installs, we disable interactive configuration steps.
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

VERSION=7.2.4
INSTALLED_VERSION=`/usr/sbin/VBoxService --version`
RC=$?

if [ $RC -eq 0 ]; then
	echo -e "VBoxGuestAdditions installed version: $INSTALLED_VERSION"
	INSTALLED_VERSION=${INSTALLED_VERSION%r*}
	if [ $INSTALLED_VERSION == $VERSION ]; then
		echo -e "No update is needed"
		exit 0
	fi
else
	echo -e "VBoxGuestAdditions are not installed"
fi

if [ $RC -ne 0 ]; then
	echo -e "Installing VBoxGuestAdditions_$VERSION"
elif [ $INSTALLED_VERSION != $VERSION ]; then
	echo -e "Updating VBoxGuestAdditions_$INSTALLED_VERSION to $VERSION"
fi

apt-get update
apt-get -y install linux-headers-$(uname -r) build-essential dkms libxt6 libxmu-dev libxt-dev

if [ ! -f /tmp/VBoxGuestAdditions_$VERSION.iso ]; then
	echo -e "Downloading VBoxGuestAdditions_$VERSION"
	wget https://download.virtualbox.org/virtualbox/$VERSION/VBoxGuestAdditions_$VERSION.iso
	mv VBoxGuestAdditions_$VERSION.iso /tmp
fi

mkdir /mnt/VBoxGuestAdditions &> /dev/null
mount -o loop,ro /tmp/VBoxGuestAdditions_$VERSION.iso /mnt/VBoxGuestAdditions

if [ ! -f /usr/sbin/vbox-uninstall-guest-additions ]; then
	sh /mnt/VBoxGuestAdditions/VBoxLinuxAdditions.run uninstall --force
else
	/usr/sbin/vbox-uninstall-guest-additions
fi

sh /mnt/VBoxGuestAdditions/VBoxLinuxAdditions.run
umount /mnt/VBoxGuestAdditions
rmdir /mnt/VBoxGuestAdditions
rm /tmp/VBoxGuestAdditions_$VERSION.iso

echo "==> Vbox guest addons installation script complete."
