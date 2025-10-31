#!/bin/sh -eux

echo "==> Running cleanup script..."

if [ -f "/bin/dnf" ]; then
	dnf autoremove -y
	dnf clean all
elif [ -f "/usr/bin/apt-get" ]; then
	apt-get autoremove -y
	apt-get clean -y
elif [ -f "/usr/bin/zypper" ]; then
	zypper remove-orphans
	zypper clean --all
elif [ -f "/usr/bin/apk" ]; then
	apk cache clean
	rm -rf /var/cache/apk/*
fi

# Remove temporary files
find /var/cache -type f -exec rm -rf {} \;
rm -rf /tmp/* /var/tmp/*

# Remove machine-id to force regeneration on first boot
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Force a new random seed to be generated"
rm -f /var/lib/systemd/random-seed

# Clear bash history (if bash is used)
unset HISTFILE
if [ -f /home/vagrant/.bash_history ]; then
  rm -f /root/.bash_history
  rm -f /home/vagrant/.bash_history
fi

# Clear ash history (Default Alpine shell)
if [ -f /home/vagrant/.ash_history ]; then
  rm -f /root/.ash_history
  rm -f /home/vagrant/.ash_history
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

echo "==> Cleanup complete."
