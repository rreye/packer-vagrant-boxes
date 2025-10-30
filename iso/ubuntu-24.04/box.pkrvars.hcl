// File: iso/ubuntu-24.04/box.pkrvars.hcl
box_name    = "ubuntu-24.04"
box_version = "1.0.0"

# Guest OS types
guest_os_type_vbox         = "Ubuntu_64"
guest_os_type_vmware_amd64 = "ubuntu-64"
guest_os_type_vmware_arm64 = "arm-ubuntu-64"

# ISO URLs and checksums (Verify these before running!)
iso_url_amd64      = "https://releases.ubuntu.com/24.04/ubuntu-24.04.3-live-server-amd64.iso"
iso_checksum_amd64 = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
iso_url_arm64      = "https://cdimage.ubuntu.com/releases/24.04/release/ubuntu-24.04.3-live-server-arm64.iso"
iso_checksum_arm64 = "sha256:2ee2163c9b901ff5926400e80759088ff3b879982a3956c02100495b489fd555"

# Autoinstall configuration
http_directory = "http" # Contains user-data and meta-data
boot_command = [
  "<wait5s>",
  "c<wait>",     # Select boot command prompt
  "linux /casper/vmlinuz ip=dhcp autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ net.ifnames=0<enter><wait>",
  "<wait5s>",
  "initrd /casper/initrd<enter><wait>",
  "boot<enter><wait>"
]

# User/password for initial SSH
ssh_username = "vagrant"
ssh_password = "vagrant"

# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S shutdown -h now"

# Scripts to run after OS install
provision_scripts = [
  "scripts/provision-ubuntu.sh",
  "scripts/vagrant.sh",
  "scripts/cleanup-ubuntu.sh"
]
