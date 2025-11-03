#!/bin/sh -eux

echo "==> Configuring Grub..."

NEW_TIMEOUT=5  # segundos
DISTRO_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

echo "==> Detecting distro: $DISTRO_ID"

case "$DISTRO_ID" in
  ubuntu|debian)
    echo "-> Ubuntu/Debian"
    sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=${NEW_TIMEOUT}/" /etc/default/grub
    sudo update-grub
    ;;

  rocky|rhel|centos|almalinux|fedora)
    echo "-> Rocky/RHEL/Fedora"
    sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=${NEW_TIMEOUT}/" /etc/default/grub
    if [ -d /sys/firmware/efi ]; then
      CFG_PATH="/boot/efi/EFI/$(ls /boot/efi/EFI | head -n1)/grub.cfg"
    else
      CFG_PATH="/boot/grub2/grub.cfg"
    fi
    sudo grub2-mkconfig -o "$CFG_PATH"
    ;;

  opensuse*|suse)
    echo "-> openSUSE"
    sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=${NEW_TIMEOUT}/" /etc/default/grub
    CFG_PATH="/boot/grub2/grub.cfg"
    sudo grub2-mkconfig -o "$CFG_PATH"
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
      echo "   No GRUB nor syslinux, aborta."
      exit 1
    fi
    ;;

  *)
    echo "Distro unknown: $DISTRO_ID"
    exit 1
    ;;
esac

echo "Timeout set to ${NEW_TIMEOUT}s."

echo "==> Grub configuration complete."
