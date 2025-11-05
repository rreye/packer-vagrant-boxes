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
RESERVE_MB=10
PARTITIONS=$(
  lsblk -lnpo MOUNTPOINT,FSTYPE |
  awk '$1 != "" && $2 ~ /ext[234]|xfs|btrfs|vfat|f2fs/ {print $1}' |
  sort |
  grep -v "^/$" |
  { cat; printf "/\n"; }
)
echo "### Partitions detected:"
printf "%s\n" "$PARTITIONS"

wipe_partition() {
    local mountpoint="$1"
    local available
    available=$(df --sync -BM -P "$mountpoint" | awk 'END{print $4}' | sed 's/M//')

    if [ "$available" -le "$RESERVE_MB" ]; then
        echo "Skipping ${mountpoint}: not enough free space (${available} MB)"
        return
    fi

    local wipe_mb=$((available - RESERVE_MB))
    echo "Filling ${wipe_mb} MB of free space with zeros..."

    local outfile="${mountpoint%/}/whitespace"
    [ "$mountpoint" = "/" ] && outfile="/whitespace"

    dd if=/dev/zero of="$outfile" bs=1M count="$wipe_mb" status=none || true
    rm -f "$outfile"
    sync
}

# Try automatic SSD trim if available
if command -v fstrim >/dev/null 2>&1; then
    echo "### Running fstrim on all mounted partitions..."
    fstrim -av || true
fi

# Wipe partitions
printf "%s\n" "$PARTITIONS" | while IFS= read -r PART; do
  [ -z "$PART" ] && continue
  echo "-> Wiping free space in $PART"
  wipe_partition "$PART"
done

echo "==> Locating swap partitions..."
set +e
swapuuid="$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)";
case "$?" in
    2|0) ;;
    *) echo "No swap partition found by blkid. Skipping swap zero."
    swapuuid=""
    ;;
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

echo "==> Final sync to disk..."
sync

echo "==> Cleanup complete."
