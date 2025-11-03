// File: iso/debian-13/box.pkrvars.hcl
box_name    = "debian-13"
box_version = "1.0.0"

# Guest OS types
guest_os_type_vbox = "Debian_64"
guest_os_type_vmware_amd64 = "debian12-64" // VMware no tendrá "debian13" aún
guest_os_type_vmware_arm64 = "arm-debian12-64"

# ISO URLs and checksums (Verify these before running!)
iso_url_amd64      = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.1.0-amd64-netinst.iso"
iso_checksum_amd64 = "sha256:658b28e209b578fe788ec5867deebae57b6aac5fce3692bbb116bab9c65568b3"
iso_url_arm64      = "https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/debian-13.1.0-arm64-netinst.iso"
iso_checksum_arm64 = "sha256:9ecd75a62d90ecedfc3f7fcdf46c349bb4ebfb79553514c9d96239cd9bada820"

# Autoinstall configuration
http_directory = "http" # Contains preseed.cfg
boot_command = [
  "<wait5s>",
  "install ",
  "auto=true ",
  "priority=critical ",
  "preseed/url=http://{{ .HttpAddr }}/preseed.cfg ",
  "initrd=/install.amd/initrd.gz ",
  "<enter><wait>"
]

# Execute command
execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"

# User/password for initial SSH
ssh_username = "vagrant"
ssh_password = "vagrant"

# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S shutdown -h now"

# Scripts to run after OS install
provision_scripts = ["scripts/provision-debian.sh"]
