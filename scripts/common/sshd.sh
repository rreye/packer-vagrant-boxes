#!/bin/sh -eux

echo "==> Configuring SSHD..."

if [ -f "/etc/ssh/sshd_config" ]; then
  SSHD_CONFIG="/etc/ssh/sshd_config"
elif [ -f "/usr/etc/ssh/sshd_config" ]; then
  SSHD_CONFIG="/usr/etc/ssh/sshd_config"
else
  echo "Unable to find sshd_config"
  exit 1
fi

# Asegurar que el directorio .d existe
SSHD_D="${SSHD_CONFIG}.d"
if [ ! -d "$SSHD_D" ]; then
    mkdir -p "$SSHD_D"
fi

# Añadir el Include
# Importante: Usamos la ruta absoluta para evitar ambigüedades
if ! grep -iq "^Include $SSHD_D/\*.conf" "$SSHD_CONFIG"; then
    echo "Adding Include directive to $SSHD_CONFIG"
    # Añadir al principio del archivo para que tenga prioridad
    sed -i "1iInclude $SSHD_D/*.conf" "$SSHD_CONFIG"
fi

# Crear el fichero de configuración personalizado
# Usamos 99- para que sea lo último en cargar (o lo primero según la distro, 
# pero asegura que sobreescriba valores por defecto)
cat <<EOF > "$SSHD_D/99-sshd-custom.conf"
PermitRootLogin yes
PasswordAuthentication yes
KbdInteractiveAuthentication yes
UseDNS no
Subsystem sftp internal-sftp
EOF

sed -i 's/^[[:space:]]*Subsystem[[:space:]]\+sftp/#&/' $SSHD_CONFIG

# Validar sintaxis
if sshd -t; then
    echo "SSHD configuration is valid."
else
    echo "ERROR: Invalid SSHD configuration detected."
    exit 1
fi

# Reiniciar el servicio
if [ -f /etc/alpine-release ]; then
  echo "Alpine detected. Using 'rc-service sshd'."
  rc-service sshd restart
elif command -v systemctl > /dev/null 2>&1; then
  echo "Systemd detected. Checking for 'ssh.service' vs. 'sshd.service'..."
  if systemctl list-units --type=service | grep -q "ssh.service"; then
    # Debian/Ubuntu
    echo "Found 'ssh.service' (Debian/Ubuntu style)."
    systemctl restart ssh
  elif systemctl list-units --type=service | grep -q "sshd.service"; then
    echo "Found 'sshd.service' (RHEL/SUSE style)."
    systemctl restart sshd
  else
    # Si no están activos pero existen (ej. primer arranque)
    systemctl restart sshd || systemctl restart ssh
  fi
else
  # Fallback para sistemas legacy o antiguos
  rc-service sshd restart || service sshd restart || service ssh restart || /etc/init.d/sshd restart
fi

echo "Standardizing /etc/hosts..."
# Leer el hostname directamente del kernel, evadiendo la necesidad del comando 'hostname'
CURRENT_HOSTNAME=$(cat /proc/sys/kernel/hostname | cut -d. -f1)
sed -i '/packer-/d' /etc/hosts
sed -i '/^127\.0\.1\.1/d' /etc/hosts
sed -i "/^127\.0\.0\.1/a 127.0.1.1\t$CURRENT_HOSTNAME" /etc/hosts

echo "==> SSHD configuration complete."
