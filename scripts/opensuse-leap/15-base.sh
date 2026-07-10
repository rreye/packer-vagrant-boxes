#!/bin/bash -eux

echo "==> Running provision script (OpenSuse Leap 15)..."

# Install common tools
zypper clean --all
zypper refresh
zypper install -y vim nano git curl wget tree net-tools openssh rsync tar unzip sudo gpg2 glibc-locale glibc-i18ndata

localedef -i es_ES -f UTF-8 es_ES.UTF-8
localectl set-locale LANG=es_ES.UTF-8
if [ -f /bin/bash ]; then
    HOME_DIR=/home/vagrant
    echo 'export LC_ALL=es_ES.UTF-8' >> $HOME_DIR/.bashrc
    echo 'export LANG=es_ES.UTF-8' >> $HOME_DIR/.bashrc
    echo 'export LANGUAGE=es_ES.UTF-8' >> $HOME_DIR/.bashrc
fi

rm -f /usr/lib/motd.d/welcome
rm -f /root/autoinst.xml
# Limpiar los logs de instalación del sistema
rm -rf /var/log/YaST2/*

if systemctl is-active --quiet apparmor; then
    echo "Disabling AppArmor..."
    systemctl stop apparmor
    systemctl disable apparmor
    
    CONFIG_FILE="/etc/default/grub"
    
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
        # Inyectar apparmor=0 en los parámetros del kernel si no está ya presente
        if ! grep -q "apparmor=0" "$CONFIG_FILE"; then
            sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="apparmor=0 /' "$CONFIG_FILE"
            # update-bootloader es la herramienta nativa de SUSE.
            # Se encarga automáticamente de detectar si es EFI o BIOS y regenerar la configuración correcta.
            update-bootloader --refresh
        fi
    else
        echo "ERROR: GRUB config file not found at $CONFIG_FILE"
        exit 1
    fi
fi

echo "==> Provisioning complete."
