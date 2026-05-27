#!/bin/sh
apk add sudo efibootmgr

# Capturamos el ID del dispositivo desde el que estamos arrancados AHORA mismo (CD-ROM de Packer)
CURRENT_BOOT=$(efibootmgr | grep '^BootCurrent:' | awk '{print $2}')
echo "Currently booted from ISO (CD/DVD):: $CURRENT_BOOT"

# Buscamos la entrada creada por Alpine o el Disco Duro, ignorando explícitamente CD/DVD/PXE
# Buscamos la primera entrada de arranque válida, EXCLUYENDO explícitamente:
# - El dispositivo actual (-v "Boot${CURRENT_BOOT}")
# - El menú de la BIOS (-v "UiApp")
# - La consola EFI (-v "Shell")
# - Arranque por red (-v "PXE" y -v "Network")
BOOT_ID=$(efibootmgr | grep -E '^Boot[0-9A-Fa-f]{4}' | grep -i -v -E "Boot${CURRENT_BOOT}|UiApp|Shell|PXE|Network" | head -n 1 | cut -c 5-8)

if [ -n "$BOOT_ID" ]; then
    echo "-> Hard drive detected in the EFI entry: $BOOT_ID"
    echo "-> Setting as priority boot..."
    efibootmgr -n "$BOOT_ID"
    efibootmgr -o "$BOOT_ID"
else
    echo "WARNING: No alternative CD-ROM input was found"
    efibootmgr
fi
