#!/bin/bash -eux

echo "==> Running provision script (Rocky 9.6)..."

cat << 'EOF' | sudo tee /etc/yum.repos.d/rocky-9.6-vault.repo
[rocky-9.6-baseos]
name=Rocky Linux 9.6 - BaseOS (Vault)
baseurl=https://dl.rockylinux.org/vault/rocky/9.6/BaseOS/x86_64/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-9

[rocky-9.6-appstream]
name=Rocky Linux 9.6 - AppStream (Vault)
baseurl=https://dl.rockylinux.org/vault/rocky/9.6/AppStream/x86_64/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-9

[rocky-9.6-extras]
name=Rocky Linux 9.6 - Extras (Vault)
baseurl=https://dl.rockylinux.org/vault/rocky/9.6/extras/x86_64/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-9
EOF

# Disable all repos
dnf config-manager --set-disabled \*

# Enable only vault repos and update
dnf config-manager --set-enabled rocky-9.6-baseos
dnf config-manager --set-enabled rocky-9.6-appstream
dnf config-manager --set-enabled rocky-9.6-extras
curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-9 https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-9
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-9
dnf clean all
dnf makecache
dnf repolist
dnf update -y

echo "==> Provisioning complete."
