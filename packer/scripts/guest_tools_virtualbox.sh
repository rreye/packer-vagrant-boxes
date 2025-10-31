#!/bin/sh -eux

echo "==> Running guest virtualbox tools script..."

VERSION=7.2.4
ARCHITECTURE="$(uname -m)";

if command -v VBoxService >/dev/null 2>&1; then
	INSTALLED_VERSION=$(VBoxService --version || true)
	echo -e "VBoxGuestAdditions installed version: $INSTALLED_VERSION"
	INSTALLED_VERSION=${INSTALLED_VERSION%r*}
	if [ $INSTALLED_VERSION == $VERSION ]; then
		echo -e "No update is needed"
		exit 0
	else
		echo -e "Updating VBoxGuestAdditions_$INSTALLED_VERSION to $VERSION for architecture $ARCHITECTURE"
	fi
else
	echo -e "VBoxGuestAdditions are not installed"
	echo -e "Installing VBoxGuestAdditions_$VERSION for architecture $ARCHITECTURE"
fi

if [ -f "/usr/bin/dnf" ]; then
	dnf update
	dnf install -y --skip-broken cpp gcc make bzip2 tar kernel-headers kernel-devel kernel-uek-devel || true # not all these packages are on every system
elif [ -f "/usr/bin/apt-get" ]; then
	export DEBIAN_FRONTEND=noninteractive
	export DEBCONF_NONINTERACTIVE_SEEN=true
	apt-get update -y
	apt-get install -y build-essential dkms bzip2 tar linux-headers-"$(uname -r)"
elif [ -f "/usr/bin/zypper" ]; then
	zypper refresh -y
	zypper install -y perl cpp gcc make bzip2 tar kernel-default-devel
elif [ -f "/sbin/apk" ]; then
	apk update
	apk add --no-cache make gcc perl linux-headers
fi

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

if [ "$ARCHITECTURE" = "aarch64" ]; then
	/mnt/VBoxGuestAdditions/VBoxLinuxAdditions-arm64.run --nox11 || true
else
	/mnt/VBoxGuestAdditions/VBoxLinuxAdditions.run --nox11 || true
fi

umount /mnt/VBoxGuestAdditions
rmdir /mnt/VBoxGuestAdditions
rm /tmp/VBoxGuestAdditions_$VERSION.iso

if ! modinfo vboxsf >/dev/null 2>&1; then
	echo "Cannot find vbox kernel module. Installation of guest additions unsuccessful!"
	exit 1
fi

echo "==> Guest virtualbox tools complete."
