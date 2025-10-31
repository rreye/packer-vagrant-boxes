#!/bin/bash -eux

echo "==> Running provision script (Rocky)..."

# Update packages
dnf clean all
dnf update -y

# Install common tools (some might be installed by Kickstart already)
dnf install -y vim nano git curl wget tree net-tools openssh-server rsync unzip sudo gnupg

# Optional: Enable EPEL repository for more packages
dnf install -y epel-release
dnf update -y

echo "==> Provisioning complete."
