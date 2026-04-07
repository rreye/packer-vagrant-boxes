#!/bin/sh -eux

echo "==> Running cleanup script..."

if [ -f /etc/sudoers.d/_packer_env ]; then
  rm -f /etc/sudoers.d/_packer_env
fi

if [ -f "/usr/bin/dnf" ]; then
	echo "==> Cleaning DNF (RHEL/Fedora/Alma/Rocky)..."
	# Purge old kernels
	dnf -y remove "$(dnf repoquery --installonly --latest-limit=-1 -q)"
	# Remove linux firmware
	distro="$(rpm -qf --queryformat '%{NAME}' /etc/redhat-release | cut -f 1 -d '-')"
	if [ "$distro" != 'oraclelinux' ]; then
  		dnf -y remove linux-firmware
	fi
	
	# Standard cleanup
	dnf autoremove -y
	dnf clean all --enablerepo=\*
	rm -rf /var/cache/dnf/*
elif [ -f "/usr/bin/apt-get" ]; then
	echo "==> Cleaning APT (Debian/Ubuntu)..."
	# Purge old kernels
	dpkg --list | awk '{ print $2 }' \
    	    | grep 'linux-image-.*-generic' || true \
    	    | grep -v "$(uname -r)" || true \
    	    | xargs -r apt-get -y purge;

	# Exclude the files we don't need w/o uninstalling linux-firmware
	cat <<_EOF_ | cat >> /etc/dpkg/dpkg.cfg.d/excludes
#BENTO-BEGIN
path-exclude=/lib/firmware/*
path-exclude=/usr/share/doc/linux-firmware/*
#BENTO-END
_EOF_
	# Remove linux firmware
	rm -rf /lib/firmware/*
	rm -rf /usr/share/doc/linux-firmware/*

	# Standard cleanup
	apt-get autoremove -y
	apt-get clean -y
	apt-get autoclean
	rm -rf /var/lib/apt/lists/*
	rm -rf /var/cache/apt/archives/*
elif [ -f "/usr/bin/zypper" ]; then
	echo "==> Cleaning Zypper (SUSE/openSUSE)..."
	# Purge old kernels
	zypper purge-kernels
	# Remove linux firmware
	zypper rm -u kernel-firmware
	ORPHANS=$(zypper -q packages --orphaned | awk '{print $5}')
    	if [ -n "$ORPHANS" ]; then
      		zypper -n rm $ORPHANS
    	fi
	zypper clean --all
	rm -rf /var/cache/zypp/packages/*
elif [ -f "/sbin/apk" ]; then
	echo "==> Cleaning APK (Alpine)..."
	# Remove linux firmware
	apk del linux-firmware
	apk cache clean
	rm -rf /var/cache/apk/*
fi

# Remove temporary files, logs and other files
rm -rf /tmp/* /var/tmp/*
find /var/log -type f -exec sh -c '> "$1"' _ {} \;
cat /dev/null > /var/log/wtmp
cat /dev/null > /var/log/lastlog

echo "==> Cleaning DHCP leases..."
rm -f /var/lib/dhcp/*
rm -f /var/lib/dhcpv6/*
rm -f /var/lib/dhclient/*
rm -f /var/lib/NetworkManager/*.lease
rm -f /var/lib/wicked/*
# Para sistemas modernos con systemd-networkd
rm -rf /var/lib/systemd/network/mac1* 2>/dev/null || true

# Remove machine-id to force regeneration on first boot
sed -i '/127.0.1.1.*packer-*/d' /etc/hosts
if [ -f "/etc/machine-id" ]; then
	truncate -s 0 /etc/machine-id
fi

if [ -f "/var/lib/dbus/machine-id" ]; then
	rm -f /var/lib/dbus/machine-id
	ln -s /etc/machine-id /var/lib/dbus/machine-id
fi

# Force a new random seed to be generated"
if [ -f "/var/lib/systemd/random-seed" ]; then
  rm -f /var/lib/systemd/random-seed
fi

echo "==> Clearing shell history..."
unset HISTFILE
rm -f /root/.wget-hsts
rm -rf /root/.cache
rm -rf /root/.viminfo
# Clear bash history (if bash is used)
if [ -f /home/vagrant/.bash_history ]; then
  rm -f /home/vagrant/.bash_history
fi
if [ -f /root/vagrant/.bash_history ]; then
  rm -f /root/.bash_history
fi
# Clear ash history (Default Alpine shell)
if [ -f /home/vagrant/.ash_history ]; then
  rm -f /home/vagrant/.ash_history
fi
if [ -f /root/vagrant/.ash_history ]; then
  rm -f /root/.ash_history
fi

echo "==> Cleanup complete."
