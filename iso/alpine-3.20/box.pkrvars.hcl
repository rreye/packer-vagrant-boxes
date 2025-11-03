// File: iso/alpine-3.20/box.pkrvars.hcl
box_name    = "alpine-3.20"
box_version = "1.0.0"

# Guest OS types
guest_os_type_vbox         = "Linux26_64" # Generic Linux
guest_os_type_vmware_amd64 = "other-64"
guest_os_type_vmware_arm64 = "arm-other-64"

# ISO URLs and checksums (Verify!)
# NOTE: Alpine uses different images (std vs virt). Use 'virt' for VMs.
iso_url_amd64      = "https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/alpine-virt-3.20.8-x86_64.iso"
iso_checksum_amd64 = "sha256:a5cfa6d96aef1571992c43231c046aacccc2eb34267c6f8788dbd590ba25591a"
iso_url_arm64      = "https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/aarch64/alpine-virt-3.20.8-aarch64.iso"
iso_checksum_arm64 = "sha256:3ac4cc127127592b454b7c804cb88a9155462f63197c43339766150a90f6d95e"

# Alpine Answer File setup
http_directory = "http" # Contains answerfile
boot_command = [
    # Boot sequence for Alpine setup with answerfile via HTTP
    "root<enter>",                # Login as root (no password initially)
    "ifconfig eth0 up<enter><wait>",
    "udhcpc -i eth0<enter><wait2s>",	# Configure network via DHCP
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/answerfile<enter><wait>", # Download answerfile
    "echo \"root:vagrant\" | chpasswd -m<enter><wait>",
    "mkdir -p /etc/ssh/sshd_config.d<enter>",
    "echo \"PermitRootLogin yes\" > /etc/ssh/sshd_config.d/root.conf<enter>",
    "yes | setup-alpine -e -f answerfile<enter><wait20s>", 	# Run setup with answerfile
    "reboot<enter>"
]

# User/password for initial SSH (setup in answerfile)
ssh_username = "root"
ssh_password = "vagrant"

# Execute command
execute_command = "{{.Vars}} sh -eux '{{.Path}}'"

# Reboot command
reboot_command = "reboot"

# Shutdown command
shutdown_command = "poweroff"

# Scripts
provision_scripts = ["scripts/provision-alpine.sh"]
