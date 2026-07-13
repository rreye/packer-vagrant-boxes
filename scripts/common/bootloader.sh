#!/bin/sh -eux

echo "==> Configuring Bootloader (GRUB/Syslinux/Extlinux)..."

. /tmp/grub_helpers.sh

NEW_TIMEOUT=5  # seconds
DISTRO_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
echo "==> Detecting distro: $DISTRO_ID"

CONFIG_FILE="/etc/default/grub"
GRUB_CHANGED=0

case "$DISTRO_ID" in
  ubuntu|debian)
    echo "-> Ubuntu/Debian"    
    set_grub_timeout "$CONFIG_FILE"
    disable_predictable_netnames "$CONFIG_FILE"
    remove_crashkernel "$CONFIG_FILE"
    ;;

  rocky|rhel|centos|almalinux|fedora)
    echo "-> RHEL family"
    set_grub_timeout "$CONFIG_FILE"
    disable_predictable_netnames "$CONFIG_FILE"
    remove_crashkernel "$CONFIG_FILE"
    ;;

  opensuse*|suse|sles)
    echo "-> SUSE family"
    set_grub_timeout "$CONFIG_FILE"
    disable_predictable_netnames "$CONFIG_FILE"
    remove_crashkernel "$CONFIG_FILE"
    ;;

  alpine)
    echo "-> Alpine"
    if [ -f /boot/syslinux/syslinux.cfg ]; then
      	echo "   (syslinux)"
      	# syslinux nativo usa décimas de segundo
      	SYSL_TIMEOUT=$((NEW_TIMEOUT * 10))
      	sed -i "s/^TIMEOUT.*/TIMEOUT ${SYSL_TIMEOUT}/" /boot/syslinux/syslinux.cfg
      	
      	# Desactivar red predecible en la línea APPEND de syslinux
        if ! grep -q "net.ifnames=0" /boot/syslinux/syslinux.cfg; then
           sed -i 's/^\([[:space:]]*APPEND.*\)/\1 net.ifnames=0 biosdevname=0/' /boot/syslinux/syslinux.cfg
        fi
    elif [ -f /etc/default/grub ]; then
      	echo "   (GRUB)"
      	set_grub_timeout_minimal "$CONFIG_FILE"
      	disable_predictable_netnames "$CONFIG_FILE"
    elif [ -f /etc/update-extlinux.conf ]; then
        echo "   (extlinux)"
        # Wrapper de Alpine usa segundos
        sed -i "s/^timeout=.*/timeout=${NEW_TIMEOUT}/" /etc/update-extlinux.conf
        
        # Inyectar los parámetros de red en default_kernel_opts
        if ! grep -q "net.ifnames=0" /etc/update-extlinux.conf; then
            sed -i 's/^default_kernel_opts="\(.*\)"/default_kernel_opts="\1 net.ifnames=0 biosdevname=0"/' /etc/update-extlinux.conf
        fi
        # Comando obligatorio de Alpine para regenerar /boot/extlinux.conf
        update-extlinux
    else
    	echo "   (efibootmgr/aboot or unknown bootloader)"
      	echo "   No GRUB/syslinux config found. This is normal for fast-boot EFI."
      	echo "   Skipping configuration."
    fi
    ;;

  *)
    echo "Distro unknown: $DISTRO_ID"
    exit 1
    ;;
esac

apply_grub_changes "$DISTRO_ID"

echo "==> Bootloader configuration complete."
