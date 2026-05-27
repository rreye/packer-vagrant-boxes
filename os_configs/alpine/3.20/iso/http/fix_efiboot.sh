#!/bin/sh
apk add sudo efibootmgr

# Buscamos la entrada creada por Alpine o el Disco Duro, ignorando explícitamente CD/DVD/PXE
BOOT_ID=$(efibootmgr | grep -i -E 'alpine|hard|hd|virtio' | grep -i -v 'cd|dvd|pxe' | head -n 1 | cut -c 5-8)

if [ -n "$BOOT_ID" ]; then
    echo "Setting the priority boot to the EFI input: $BOOT_ID"
    efibootmgr -n "$BOOT_ID"
    efibootmgr -o "$BOOT_ID"
else
    echo "WARNING: The disk's EFI entry could not be dynamically detected"
fi
