#!/bin/sh -eux

echo "==> Configuring Bootloader (GRUB/Syslinux)..."

NEW_TIMEOUT=5  # segundos
DISTRO_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

set_grub_timeout() {
  FILE="$1"
  if grep -q "^GRUB_TIMEOUT=" "$FILE"; then
    sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=${NEW_TIMEOUT}/" "$FILE"
  else
    echo "GRUB_TIMEOUT=${NEW_TIMEOUT}" >> "$FILE"
  fi
  if grep -q "^GRUB_RECORDFAIL_TIMEOUT=" "$FILE"; then
    sed -i "s/^GRUB_RECORDFAIL_TIMEOUT=.*/GRUB_RECORDFAIL_TIMEOUT=0/" "$FILE"
  else
    echo "GRUB_RECORDFAIL_TIMEOUT=0" >> "$FILE"
  fi
  if grep -q "^GRUB_TIMEOUT_STYLE=" "$FILE"; then
    sed -i "s/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/" "$FILE"
  else
    echo "GRUB_TIMEOUT_STYLE=menu" >> "$FILE"
  fi
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

disable_predictable_netnames() {
  FILE="$1"
  if ! grep -q "net.ifnames=0" "$FILE"; then
    if grep -q "^GRUB_CMDLINE_LINUX=" "$FILE"; then
      # Añade los parámetros dentro de las comillas existentes
      sed -i -e 's|^GRUB_CMDLINE_LINUX="\(.*\)"|GRUB_CMDLINE_LINUX="\1 net.ifnames=0 biosdevname=0"|' "$FILE"
    else
      # Si no existe, crea la variable
      echo 'GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"' >> "$FILE"
    fi
  fi
}

echo "==> Detecting distro: $DISTRO_ID"

case "$DISTRO_ID" in
  ubuntu|debian)
    echo "-> Ubuntu/Debian"
    
    if [ -f /etc/default/grub ]; then
    	set_grub_timeout /etc/default/grub
    	disable_predictable_netnames /etc/default/grub
    	update-grub
    else
    	echo "   No /etc/default/grub found. Skipping."
    fi
    ;;

  rocky|rhel|centos|almalinux|fedora|opensuse*|suse)
    echo "-> RHEL/SUSE family"
    
    if [ -f /etc/default/grub ]; then
    	set_grub_timeout /etc/default/grub
    	disable_predictable_netnames /etc/default/grub
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
      	# Desactivar red predecible en la línea APPEND de syslinux
        if ! grep -q "net.ifnames=0" /boot/syslinux/syslinux.cfg; then
           sed -i 's/^\([[:space:]]*APPEND.*\)/\1 net.ifnames=0 biosdevname=0/' /boot/syslinux/syslinux.cfg
        fi
    elif [ -f /etc/default/grub ]; then
      	echo "   (GRUB)"
      	set_grub_timeout /etc/default/grub
      	disable_predictable_netnames /etc/default/grub
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

sleep 2
echo "Bootloader timeout set to ${NEW_TIMEOUT}s."

echo "==> Bootloader configuration complete."
