#!/bin/sh -eux

echo "==> Running guest virtualbox tools script..."

VERSION=7.2.12
ARCHITECTURE="$(uname -m)"
KERNEL_VERSION="$(uname -r)"

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

echo "Kernel version: $KERNEL_VERSION"

if [ -f "/usr/bin/dnf" ]; then
        dnf remove -y virtualbox-guest-additions virtualbox-guest-tools || true
	dnf install --refresh -y cpp gcc make bzip2 tar elfutils-libelf-devel kernel-headers-"$KERNEL_VERSION" kernel-devel-"$KERNEL_VERSION"
elif [ -f "/usr/bin/apt-get" ]; then
	export DEBIAN_FRONTEND=noninteractive
	export DEBCONF_NONINTERACTIVE_SEEN=true
	apt-get purge -y virtualbox-guest-utils virtualbox-guest-x11 virtualbox-guest-dkms || true
	apt-get install -y build-essential dkms bzip2 tar linux-headers-"$KERNEL_VERSION"
elif [ -f "/usr/bin/zypper" ]; then
        zypper -n rm -u virtualbox-guest-tools virtualbox-guest-x11 virtualbox-kmp-default || true
	zypper install -y cpp gcc make bzip2 tar kernel-default-devel
elif [ -f "/sbin/apk" ]; then
	if [ "$ARCHITECTURE" = "aarch64" ]; then
		echo "==> Alpine ARM64 detected. No Guest virtualbox tools available"
		exit 0
	fi

	echo "==> Alpine x86_64 detected. Installing using apk"
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

if [ -f /usr/sbin/vbox-uninstall-guest-additions ]; then
	echo "Uninstalling..."
	/usr/sbin/vbox-uninstall-guest-additions
fi

echo "Running install script..."
if [ "$ARCHITECTURE" = "aarch64" ]; then
	echo "yes" | /mnt/VBoxGuestAdditions/VBoxLinuxAdditions-arm64.run --nox11 || true
else
	echo "yes" | /mnt/VBoxGuestAdditions/VBoxLinuxAdditions.run --nox11 || true
fi

umount /mnt/VBoxGuestAdditions
rmdir /mnt/VBoxGuestAdditions
rm /tmp/VBoxGuestAdditions_$VERSION.iso

if ! modinfo vboxsf >/dev/null 2>&1; then
	echo "Cannot find vbox kernel module. Installation of guest additions unsuccessful!"
	exit 1
fi

echo "removing kernel dev packages and compilers we no longer need"
if [ -f "/bin/dnf" ]; then
	dnf remove -y elfutils-libelf-devel kernel-headers-"$KERNEL_VERSION" kernel-devel-"$KERNEL_VERSION" cpp gcc make
	dnf autoremove -y
elif [ -f "/usr/bin/apt-get" ]; then
	apt-get purge -y --auto-remove build-essential gcc g++ make libc6-dev dkms linux-headers-"$KERNEL_VERSION"
elif [ -f "/usr/bin/zypper" ]; then
	zypper -n rm -u kernel-default-devel cpp gcc make
fi

echo "removing leftover logs"
rm -rf /var/log/vboxadd*
    
echo "==> Guest virtualbox tools complete."
