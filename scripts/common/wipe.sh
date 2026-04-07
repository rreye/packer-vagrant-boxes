#!/bin/sh -eux

echo "==> Zeroing free space to shrink box..."

RESERVE_MB=25
GA_WIPE_LIMIT_MB=32768
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
    local available=0
    available=$(df -BM -P "$mountpoint" | awk 'END{print $4}' | sed 's/M//')

    if [ "$available" -le "$RESERVE_MB" ]; then
        echo "Skipping ${mountpoint}: not enough free space (${available} MB)"
        return
    fi

    local wipe_mb=$((available - RESERVE_MB))
    echo "${wipe_mb} MB of free space in ${mountpoint}"
    if [ "$wipe_mb" -le 0 ]; then
        echo "Skipping ${mountpoint}: not enough free space (${wipe_mb} MB)"
        return
    fi
    echo "Zeroing will be limited to ${GA_WIPE_LIMIT_MB} MB"
    if [ "$wipe_mb" -gt "$GA_WIPE_LIMIT_MB" ]; then
      wipe_mb=$GA_WIPE_LIMIT_MB
    fi
    
    local outfile="${mountpoint%/}/whitespace"
    [ "$mountpoint" = "/" ] && outfile="/whitespace"
    echo "Filling ${wipe_mb} MB with zeros in ${mountpoint} using ${outfile}..."
    dd if=/dev/zero of="$outfile" bs=1M count="$wipe_mb" || echo "dd exit code $? is suppressed";
    rm "$outfile"
    sync
    sleep 5
    echo "Done!"
}

# Wipe partitions
printf "%s\n" "$PARTITIONS" | while IFS= read -r PART; do
  [ -z "$PART" ] && continue
  echo "-> Wiping free space in $PART"
  sync
  sleep 5
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
sleep 5
sync
sync

echo "==> Wipe complete."
