#!/bin/sh -eux

echo "==> Running cleanup script..."

if [ -f "/usr/bin/dnf" ]; then
	dnf autoremove -y
	dnf clean all
	rm -rf /var/cache/dnf
elif [ -f "/usr/bin/apt-get" ]; then
	apt-get autoremove -y
	apt-get clean -y
	apt-get autoclean
	rm -rf /var/lib/apt/lists/*
elif [ -f "/usr/bin/zypper" ]; then
	ORPHANS=$(zypper -q packages --orphaned | awk '{print $5}')
    	if [ -n "$ORPHANS" ]; then
      		zypper -n rm $ORPHANS
    	fi
	zypper clean --all
	rm -rf /var/cache/zypp/packages
elif [ -f "/sbin/apk" ]; then
	apk cache clean
	rm -rf /var/cache/apk/*
fi

# Remove temporary files and logs
rm -rf /tmp/* /var/tmp/*
find /var/cache -type f -exec rm -rf {} \;
find /var/log -type f -delete

# Remove machine-id to force regeneration on first boot
truncate -s 0 /etc/machine-id
if [ -f "/var/lib/dbus/machine-id" ]; then
	rm /var/lib/dbus/machine-id
	ln -s /etc/machine-id /var/lib/dbus/machine-id
fi

# Force a new random seed to be generated"
if [ -f "/var/lib/systemd/random-seed" ]; then
  rm -f /var/lib/systemd/random-seed
fi

# Clear bash history (if bash is used)
unset HISTFILE
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

echo "==> Zeroing free space to shrink box..."

# Whiteout root
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
count=$((count - 1))
echo "==> Zeroing root partition..."
dd if=/dev/zero of=/tmp/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
rm /tmp/whitespace

# Whiteout /boot
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
count=$((count - 1))
echo "==> Zeroing boot partition..."
dd if=/dev/zero of=/boot/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
rm /boot/whitespace

set +e
swapuuid="$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)";
case "$?" in
    2|0) ;;
    *) exit 1 ;;
esac
set -e

if [ "x${swapuuid}" != "x" ]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    echo "==> Zeroing swap partition..."
    swappart="$(readlink -f /dev/disk/by-uuid/"$swapuuid")";
    /sbin/swapoff "$swappart" || true;
    dd if=/dev/zero of="$swappart" bs=1M || echo "dd exit code $? is suppressed";
    chmod 0600 "$swappart" || true;
    /sbin/mkswap -U "$swapuuid" "$swappart" || echo "mkswap exit code $? is suppressed";
fi

sync;
sync;
sync;

echo "==> Cleanup complete."
