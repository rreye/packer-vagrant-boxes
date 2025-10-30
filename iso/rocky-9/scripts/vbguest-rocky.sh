#!/bin/bash -eux

echo "==> Running Vbox guest addons installation script (Rocky)..."

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
	echo -e "VBoxGuestAdditions are not installed ($INSTALLED_VERSION)"
fi

if [ $RC -ne 0 ]; then
	echo -e "Installing VBoxGuestAdditions_$VERSION"
elif [ $INSTALLED_VERSION != $VERSION ]; then
	echo -e "Updating VBoxGuestAdditions_$INSTALLED_VERSION to $VERSION"
fi

dnf update
dnf install -y tar bzip2 kernel-headers-$(uname -r) kernel-devel-$(uname -r) gcc make elfutils-libelf-devel

if [ ! -f /tmp/VBoxGuestAdditions_$VERSION.iso ]; then
	echo -e "Downloading VBoxGuestAdditions_$VERSION"
	wget https://download.virtualbox.org/virtualbox/$VERSION/VBoxGuestAdditions_$VERSION.iso &> /dev/null
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
