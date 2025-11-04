#!/bin/sh -eux

echo "==> Configuring GRUB..."

NEW_TIMEOUT=5  # segundos
DISTRO_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

set_grub_timeout() {
  FILE="$1"
  sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=${NEW_TIMEOUT}/" "$FILE" \
    || echo "GRUB_TIMEOUT=${NEW_TIMEOUT}" >> "$FILE"
}

generate_grub_cfg_rhel() {
  if [ -d /sys/firmware/efi ]; then
    # EFI
    EFI_VENDOR=$(ls /boot/efi/EFI | head -n1)
    grub2-mkconfig -o /boot/efi/EFI/${EFI_VENDOR}/grub.cfg
  else
    # BIOS
    grub2-mkconfig -o /boot/grub2/grub.cfg
  fi
}

echo "==> Detecting distro: $DISTRO_ID"

case "$DISTRO_ID" in
  ubuntu|debian)
    echo "-> Ubuntu/Debian"
    
    if [ -f /etc/default/grub ]; then
    	set_grub_timeout /etc/default/grub
    	update-grub
    else
    	echo "   No /etc/default/grub found. Skipping."
    fi
    ;;

  rocky|rhel|centos|almalinux|fedora|opensuse*|suse)
    echo "-> RHEL/SUSE family"
    
    if [ -f /etc/default/grub ]; then
    	set_grub_timeout /etc/default/grub
	generate_grub_cfg_rhel
    else
    	echo "   No /etc/default/grub found. Skipping."
    fi
    ;;

  alpine)
    echo "-> Alpine"
    if [ -f /boot/syslinux/syslinux.cfg ]; then
      	echo "   (syslinux)"
      	# syslinux usa décimas de segundo
      	SYSL_TIMEOUT=$((NEW_TIMEOUT * 10))
      	sed -i "s/^TIMEOUT.*/TIMEOUT ${SYSL_TIMEOUT}/" /boot/syslinux/syslinux.cfg
    elif [ -f /etc/default/grub ]; then
      	echo "   (GRUB)"
      	set_grub_timeout /etc/default/grub
      	grub-mkconfig -o /boot/grub/grub.cfg
    else
    	echo "   (efibootmgr/aboot or unknown bootloader)"
      	echo "   No GRUB/syslinux config found. This is normal for fast-boot EFI."
      	echo "   Skipping timeout change."
    fi
    ;;

  *)
    echo "Distro unknown: $DISTRO_ID"
    exit 1
    ;;
esac

echo "GRUB timeout set to ${NEW_TIMEOUT}s."

echo "==> GRUB configuration complete."
