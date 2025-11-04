#!/bin/sh -eux

echo "==> Configuring Grub..."

NEW_TIMEOUT=5  # segundos
DISTRO_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

echo "==> Detecting distro: $DISTRO_ID"

case "$DISTRO_ID" in
  ubuntu|debian)
    echo "-> Ubuntu/Debian"
    if [ -f /etc/default/grub ]; then
    	sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=${NEW_TIMEOUT}/" /etc/default/grub
    	sudo update-grub
    else
    	echo "   No /etc/default/grub found. Skipping."
    fi
    ;;

  rocky|rhel|centos|almalinux|fedora|opensuse*|suse)
    echo "-> RHEL/SUSE family"
    if [ -f /etc/default/grub ]; then
    	sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=${NEW_TIMEOUT}/" /etc/default/grub
    	sudo grub2-mkconfig -o /etc/default/grub
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
      	sudo sed -i "s/^TIMEOUT.*/TIMEOUT ${SYSL_TIMEOUT}/" /boot/syslinux/syslinux.cfg
    elif [ -f /etc/default/grub ]; then
      	echo "   (GRUB)"
      	sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=${NEW_TIMEOUT}/" /etc/default/grub
      	sudo grub-mkconfig -o /boot/grub/grub.cfg
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

echo "Timeout set to ${NEW_TIMEOUT}s."

echo "==> Grub configuration complete."
