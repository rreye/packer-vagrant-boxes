#!/bin/sh -eux

# Helper interno para actualizar valores Clave=Valor de forma idempotente
_set_grub_kv() {
    local key="$1"
    local val="$2"
    local file="$3"
    
    # Solo actuamos si la línea exacta (Clave=Valor) NO existe ya en el fichero
    if ! grep -q "^${key}=${val}$" "$file"; then
        if grep -q "^${key}=" "$file"; then
            sed -i "s/^${key}=.*/${key}=${val}/" "$file"
        else
            echo "${key}=${val}" >> "$file"
        fi
        # Notificamos cambio si realmente hemos modificado algo
        GRUB_CHANGED=1
    fi
}

apply_grub_changes() {
    local distro="$1"

    if [ "$GRUB_CHANGED" -eq 0 ]; then
        echo "No changes made to GRUB parameters. Bootloader update skipped."
        return 0
    fi

    echo "Changes detected in GRUB template. Updating bootloader for $distro..."

    case "$distro" in
        ubuntu|debian)
            update-grub
            ;;
            
        rocky|rhel|centos|almalinux|fedora)
            grub2-mkconfig -o /boot/grub2/grub.cfg
            ;;
            
        opensuse*|suse|sles)
            update-bootloader --refresh
            ;;
            
        alpine)
            if command -v grub-mkconfig >/dev/null 2>&1; then
                grub-mkconfig -o /boot/grub/grub.cfg
            else
                echo "Warning: grub-mkconfig not found in Alpine. Update skipped."
            fi
            ;;
            
        *)
            echo "Error: Unknown distribution '$distro'. Cannot update GRUB automatically."
            return 1 
            ;;
    esac

    GRUB_CHANGED=0
}

remove_grub_param() {
    local param="$1"
    local file="$2"
    
    # Usamos -E para soportar expresiones regulares
    if grep -E -q "$param" "$file"; then
        sed -i -e "s/[[:space:]]*$param//g" "$file"
        GRUB_CHANGED=1
    fi
}

inject_grub_param() {
    local param="$1"
    local file="$2"
    
    # Usamos -F para búsqueda estricta de cadenas
    if ! grep -F -q "$param" "$file"; then
        if grep -q "^GRUB_CMDLINE_LINUX_DEFAULT=" "$file"; then
            sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$param /" "$file"
            GRUB_CHANGED=1
        elif grep -q "^GRUB_CMDLINE_LINUX=" "$file"; then
            sed -i "s/^GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"$param /" "$file"
            GRUB_CHANGED=1
        else
            echo "GRUB_CMDLINE_LINUX=\"$param\"" >> "$file"
            GRUB_CHANGED=1
        fi
    fi
}

set_grub_timeout() {
    local file="$1"
    [ ! -f "$file" ] && { echo "   No $file found. Skipping timeout config."; return 0; }
    
    # Usamos el helper para limpiar todo el bloque de if/else repetitivos
    _set_grub_kv "GRUB_TIMEOUT" "$NEW_TIMEOUT" "$file"
    _set_grub_kv "GRUB_RECORDFAIL_TIMEOUT" "0" "$file"
    _set_grub_kv "GRUB_TIMEOUT_STYLE" "menu" "$file"
    
    echo "Bootloader timeout set to ${NEW_TIMEOUT}s."
}

set_grub_timeout_minimal() {
    local file="$1"
    [ ! -f "$file" ] && { echo "   No $file found. Skipping timeout config."; return 0; }
    
    _set_grub_kv "GRUB_TIMEOUT" "$NEW_TIMEOUT" "$file"
    
    # Para el estilo, queremos asegurarnos de que la línea se borre por completo
    if grep -q "^GRUB_TIMEOUT_STYLE=" "$file"; then
        sed -i '/^GRUB_TIMEOUT_STYLE=/d' "$file"
        GRUB_CHANGED=1
    fi
    
    echo "Bootloader timeout set to ${NEW_TIMEOUT}s (minimal)."
}

disable_predictable_netnames() {
    local file="$1"
    [ ! -f "$file" ] && { echo "   No $file found. Skipping netnames config."; return 0; }
    
    remove_grub_param "net\.ifnames=[^\" ]*" "$file"
    remove_grub_param "biosdevname=[^\" ]*" "$file"
    inject_grub_param "net.ifnames=0" "$file"
    inject_grub_param "biosdevname=0" "$file"    
    echo "Disabled predictable netnames in $file."
}

remove_crashkernel() {
    local file="$1"
    [ ! -f "$file" ] && { echo "   No $file found. Skipping crashkernel removal."; return 0; }
    
    remove_grub_param "crashkernel=[^\" ]*" "$file"
    echo "Removed crashkernel parameter from $file (if present)."
}
