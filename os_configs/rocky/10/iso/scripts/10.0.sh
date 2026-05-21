#!/bin/bash -eux

echo "==> Running provision script (Rocky 10.0)..."

cat << 'EOF' | sudo tee /etc/yum.repos.d/rocky-10.0-vault.repo
[rocky-10.0-baseos]
name=Rocky Linux 10.0 - BaseOS (Vault)
baseurl=https://dl.rockylinux.org/vault/rocky/10.0/BaseOS/$basearch/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-10

[rocky-10.0-appstream]
name=Rocky Linux 10.0 - AppStream (Vault)
baseurl=https://dl.rockylinux.org/vault/rocky/10.0/AppStream/$basearch/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-10

[rocky-10.0-extras]
name=Rocky Linux 10.0 - Extras (Vault)
baseurl=https://dl.rockylinux.org/vault/rocky/10.0/extras/$basearch/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-10
EOF

# Disable all repos
dnf config-manager --set-disabled \*

# Enable only vault repos and update
dnf config-manager --set-enabled rocky-10.0-baseos
dnf config-manager --set-enabled rocky-10.0-appstream
dnf config-manager --set-enabled rocky-10.0-extras
curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-10 https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-10
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-10
dnf clean all
dnf makecache
dnf repolist
dnf update -y

echo "==> Provisioning complete."
