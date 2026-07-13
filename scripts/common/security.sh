#!/bin/sh -eux

echo "==> Configuring security modules (AppArmor/SELinux)..."

. /tmp/grub_helpers.sh

DISTRO_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
echo "==> Detecting distro: $DISTRO_ID"

CONFIG_FILE="/etc/default/grub"
GRUB_CHANGED=0

disable_apparmor() {
    if [ -d "/sys/kernel/security/apparmor" ]; then
        echo "AppArmor detected. Disabling..."
        systemctl stop apparmor || true
        systemctl disable apparmor || true
        
        if [ -f "$CONFIG_FILE" ]; then
            remove_grub_param "security=apparmor" "$CONFIG_FILE"
            remove_grub_param "apparmor=[^\" ]*" "$CONFIG_FILE"
            inject_grub_param "apparmor=0" "$CONFIG_FILE"
        fi
    fi
}

disable_selinux() {
    if [ -d "/sys/fs/selinux" ]; then
        echo "SELinux detected. Disabling..."
        setenforce 0 || true
        
        SELINUX_CONF="/etc/selinux/config"
        if [ -f "$SELINUX_CONF" ]; then
            sed -i 's/^SELINUX=.*$/SELINUX=disabled/' "$SELINUX_CONF"
        fi

        if [ -f "$CONFIG_FILE" ]; then
            remove_grub_param "security=selinux" "$CONFIG_FILE"
            remove_grub_param "selinux=[^\" ]*" "$CONFIG_FILE"
            inject_grub_param "selinux=0" "$CONFIG_FILE"
        fi
    fi
}

case "$DISTRO_ID" in
    ubuntu|debian)
        echo "-> Ubuntu/Debian"
        disable_apparmor        
        ;;
    rocky|rhel|centos|almalinux|fedora)
        echo "-> RHEL family"
        disable_selinux
        ;;
    opensuse*|suse|sles)
        echo "-> SUSE family"
        disable_apparmor
        disable_selinux
        ;;
    alpine)
        echo "-> Alpine. No security modules to disable. Nothing to do"
        ;;
    *)
        echo "Distro unknown: $DISTRO_ID"
        exit 1
        ;;
esac

apply_grub_changes "$DISTRO_ID"

echo "==> Security modules configuration complete."
