# =============================================================================
# Preseed for Debian 12 "Bookworm"
# =============================================================================

# --- 1. Localización e Idioma ---
d-i debian-installer/language string es
d-i debian-installer/country string ES
d-i debian-installer/locale string es_ES.UTF-8
d-i console-setup/ask_detect boolean false
d-i keyboard-configuration/xkb-keymap select es
d-i debconf/frontend select noninteractive

# --- 2. Configuración de Red (DHCP) ---
# "auto" seleccionará la primera interfaz activa (ej. eth0)
d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string debian
d-i netcfg/get_domain string local
d-i netcfg/dhcp_timeout string 60
d-i netcfg/dhcp_failed note
d-i netcfg/dhcp_options select auto

# --- 3. Espejo (Mirror) de Debian ---
d-i mirror/country string manual
d-i mirror/http/hostname string deb.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string
d-i mirror/suite string bookworm
d-i apt-setup/components string main contrib non-free non-free-firmware
d-i apt-setup/use_mirror boolean false
d-i apt-setup/cdrom/set-first boolean false
d-i apt-setup/cdrom/set-next boolean false
d-i apt-setup/cdrom/set-failed boolean false
d-i apt-setup/disable-cdrom-entries boolean true

# --- 4. Configuración de Cuentas (Vagrant) ---
d-i passwd/root-login boolean true
d-i passwd/root-password password vagrant
d-i passwd/root-password-again password vagrant
d-i passwd/user-fullname string vagrant
d-i passwd/username string vagrant
d-i passwd/user-password password vagrant
d-i passwd/user-password-again password vagrant
d-i user-setup/allow-password-weak boolean true
d-i user-setup/encrypt-home boolean false

# --- 5. Reloj y Zona Horaria ---
# Configurar siempre los servidores en UTC
d-i clock-setup/utc boolean true
d-i time/zone string UTC
d-i clock-setup/ntp boolean true

# --- 6. Particionado (Simple, un solo disco) ---
# ### NEW: Forzar GPT para EFI
d-i partman-partitioning/choose_label select gpt
d-i partman-partitioning/default_label string gpt
d-i partman-efi/non_efi_system boolean true
d-i partman-auto/method string regular
# "atomic" -> Todo en una sola partición (/)
d-i partman-auto/choose_recipe select atomic
# Confirmar todos los pasos de particionado
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman/choose_partition select finish

# --- 7. Selección de Paquetes (Mínima) ---
# "standard" -> Utilidades básicas del sistema.
# "ssh-server"
tasksel tasksel/first multiselect standard, ssh-server
# Paquetes extra
d-i pkgsel/include string curl wget vim sudo ca-certificates
# NO instalar paquetes "recomendados"
d-i pkgsel/install-recommends boolean false
d-i pkgsel/upgrade select none
d-i pkgsel/update-policy select none

# --- 8. Configuración del Bootloader (GRUB) ---
# Instalar GRUB en el MBR del primer disco
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean false
d-i grub-installer/bootdev string default
d-i grub-installer/update-nvram boolean true
d-i grub-installer/force-efi-extra-removable boolean true

# Disable polularity contest
popularity-contest popularity-contest/participate boolean false

# --- 9. Comandos Finales (late_command) ---
# Se ejecuta *dentro* del nuevo sistema (/target) antes de reiniciar.
d-i preseed/late_command string \
    in-target sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' /etc/default/grub ; \
    in-target update-grub ; \
    in-target usermod -aG sudo vagrant ; \
    echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /target/etc/sudoers.d/vagrant ; \
    chmod 440 /target/etc/sudoers.d/vagrant ; \
    echo "debian" > /target/etc/hostname %{ if is_utm } ; \
    echo "allow-hotplug eth1" >> /target/etc/network/interfaces ; \
    echo "iface eth1 inet dhcp" >> /target/etc/network/interfaces %{ endif }

# --- 10. Finalización ---
d-i cdrom-detect/eject boolean true
# Evitar la pausa final de "Instalación completada"
d-i finish-install/reboot_in_progress note
