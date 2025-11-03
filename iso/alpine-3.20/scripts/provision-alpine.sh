#!/bin/sh -eux

echo "==> Running provision script (Alpine)..."

# Update packages
apk cache clean
apk update
apk upgrade

# Install common tools
apk add --no-cache vim nano git curl wget tree net-tools openssh-server rsync util-linux

# Enable community repository if needed for more packages
echo "http://dl-cdn.alpinelinux.org/alpine/v3.20/community" >> /etc/apk/repositories
apk update

echo "==> Provisioning complete."
