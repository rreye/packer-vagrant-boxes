#!/bin/bash -eux

echo "==> Running provision script (Rocky)..."

# Install common tools (some might be installed by Kickstart already)
dnf clean all
dnf install -y vim nano git curl wget tree net-tools openssh-server rsync unzip sudo gnupg langpacks-es

# Optional: Enable EPEL repository for more packages
dnf install -y epel-release

echo "Remove development and kernel source packages"
dnf -y remove gcc cpp gc kernel-devel kernel-headers glibc-devel elfutils-libelf-devel glibc-headers

echo "remove the install log"
rm -f /root/anaconda-ks.cfg /root/original-ks.cfg

echo "==> Provisioning complete."
