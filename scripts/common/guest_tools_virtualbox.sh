#!/bin/sh -eux

echo "==> Running guest virtualbox tools script..."

VERSION=7.2.4
ARCHITECTURE="$(uname -m)"

if command -v VBoxService >/dev/null 2>&1; then
	INSTALLED_VERSION=$(VBoxService --version || true)
	echo "VBoxGuestAdditions installed version: $INSTALLED_VERSION"
	INSTALLED_VERSION=${INSTALLED_VERSION%r*}
	
	if [ "$INSTALLED_VERSION" = "$VERSION" ]; then
		echo "No update is needed"
		exit 0
	else
		echo "Updating VBoxGuestAdditions_$INSTALLED_VERSION to $VERSION for architecture $ARCHITECTURE"
	fi
else
	echo "VBoxGuestAdditions are not installed"
	echo "Installing VBoxGuestAdditions_$VERSION for architecture $ARCHITECTURE"
fi

if [ -f "/usr/bin/dnf" ]; then
	dnf install --refresh -y cpp gcc make bzip2 tar kernel-headers kernel-devel
elif [ -f "/usr/bin/apt-get" ]; then
	export DEBIAN_FRONTEND=noninteractive
	export DEBCONF_NONINTERACTIVE_SEEN=true
	apt-get update -y
	apt-get install -y build-essential dkms bzip2 tar linux-headers-"$(uname -r)"
elif [ -f "/usr/bin/zypper" ]; then
	zypper refresh -y
	zypper install -y perl cpp gcc make bzip2 tar kernel-default-devel
elif [ -f "/sbin/apk" ]; then
	echo "==> Alpine detected. Installing using apk"
	apk update
	apk add --no-cache virtualbox-guest-additions
	rc-service virtualbox-guest-additions start
	rc-update add virtualbox-guest-additions boot
	echo "==> Guest virtualbox tools complete."
	exit 0
fi

if [ ! -f /tmp/VBoxGuestAdditions_$VERSION.iso ]; then
	echo "Downloading VBoxGuestAdditions_$VERSION"
	wget https://download.virtualbox.org/virtualbox/$VERSION/VBoxGuestAdditions_$VERSION.iso >/dev/null 2>&1
	mv VBoxGuestAdditions_$VERSION.iso /tmp
	if [ ! -s /tmp/VBoxGuestAdditions_$VERSION.iso ]; then
    		echo "Download failed!"
    		exit 1
	fi
fi

mkdir -p /mnt/VBoxGuestAdditions
mount -o loop,ro /tmp/VBoxGuestAdditions_$VERSION.iso /mnt/VBoxGuestAdditions

if [ ! -f /usr/sbin/vbox-uninstall-guest-additions ]; then
	sh /mnt/VBoxGuestAdditions/VBoxLinuxAdditions.run uninstall --force
else
	/usr/sbin/vbox-uninstall-guest-additions
fi

echo "Running install script..."
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
	sleep 1000
	exit 1
fi

echo "removing kernel dev packages and compilers we no longer need"
if [ -f "/bin/dnf" ]; then
	dnf remove -y gcc cpp kernel-headers kernel-devel
elif [ -f "/usr/bin/apt-get" ]; then
	apt-get remove -y build-essential gcc g++ make libc6-dev dkms linux-headers-"$(uname -r)"
elif [ -f "/usr/bin/zypper" ]; then
	zypper -n rm -u kernel-default-devel gcc make
fi

echo "removing leftover logs"
rm -rf /var/log/vboxadd*
    
echo "==> Guest virtualbox tools complete."
