#!/bin/bash

error() {
  if [ $? -ne 0 ]; then
    printf "\n\napt failed...\n\n";
    exit 1
  fi
}

# To allow for automated installs, we disable interactive configuration steps.
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Remove cloud init packages.
dpkg -l eatmydata &>/dev/null && apt-get --assume-yes purge eatmydata
dpkg -l libeatmydata1 &>/dev/null && apt-get --assume-yes purge libeatmydata1
dpkg -l cloud-init &>/dev/null && apt-get --assume-yes purge cloud-init

# Cleanup unused packages.
apt-get --assume-yes autoremove; error
apt-get --assume-yes autoclean; error

# Remove the random seed so a unique value is used the first time the box is booted.
systemctl --quiet is-active systemd-random-seed.service && systemctl stop systemd-random-seed.service
[ -f /var/lib/systemd/random-seed ] && rm --force /var/lib/systemd/random-seed
