// File: iso/rocky-9/box.pkrvars.hcl
box_name    = "rocky-9"
box_version = "1.0.0"

# Guest OS types
guest_os_type_vbox         = "RedHat_64"
guest_os_type_vmware_amd64 = "rhel9-64"
guest_os_type_vmware_arm64 = "arm-rhel9-64"

# ISO URLs and checksums (Verify!)
iso_url_amd64      = "https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.6-x86_64-minimal.iso"
iso_checksum_amd64 = "sha256:aed9449cf79eb2d1c365f4f2561f923a80451b3e8fdbf595889b4cf0ac6c58b8"
iso_url_arm64      = "https://download.rockylinux.org/pub/rocky/9/isos/aarch64/Rocky-9.6-aarch64-minimal.iso"
iso_checksum_arm64 = "sha256:4dbba6104aa1025fae5a540785e905fab7864dad118168e822042583f8020a99"

# Kickstart configuration
http_directory = "http" # Contains ks.cfg
boot_command = [
    "<tab>", # Interrupt bootloader
    " linux inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg", # Add Kickstart URL parameter
    " net.ifnames=0 biosdevname=0", # Consistent network names
    " console=tty0 console=ttyS0,115200n8", # Console output
    "<enter>" # Start boot
]

# User/password for initial SSH (defined in ks.cfg)
ssh_username = "vagrant"
ssh_password = "vagrant"

# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S /sbin/halt -h -p"

# Scripts
provision_scripts = [
  "scripts/provision-rocky.sh",
  "scripts/vagrant.sh",
  "scripts/cleanup-rocky.sh"
]
