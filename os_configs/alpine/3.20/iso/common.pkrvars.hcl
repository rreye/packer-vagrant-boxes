box_name    = "alpine-3.20"

# Guest OS types
guest_os_type_vbox_amd64   = "Linux_64"    # Generic Linux
guest_os_type_vbox_arm64   = "Linux_arm64" # Generic Linux
guest_os_type_vmware_amd64 = "other-64"
guest_os_type_vmware_arm64 = "arm-other-64"

# Alpine Answer File setup
http_directory = "http"
boot_command_amd64 = [
    # Boot sequence for Alpine setup with answerfile via HTTP
    "root<enter>",                # Login as root (no password initially)
    "ifconfig eth0 up<enter><wait>",
    "udhcpc -i eth0<enter><wait2s>",	# Configure network via DHCP
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/answerfile<enter><wait>", # Download answerfile
    "echo \"root:vagrant\" | chpasswd<enter><wait>",
    "mkdir -p /etc/ssh/sshd_config.d<enter>",
    "echo \"PermitRootLogin yes\" > /etc/ssh/sshd_config.d/root.conf<enter>",
    "setup-apkrepos -1c<enter><wait3s>",
    "apk add sudo<enter><wait>",
    "yes | setup-alpine -e -f answerfile<enter><wait45s>", 	# Run setup with answerfile
    "reboot<enter>"
]

boot_command_arm64 = [
    # Boot sequence for Alpine setup with answerfile via HTTP
    "root<enter>",                # Login as root (no password initially)
    "ifconfig eth0 up<enter><wait>",
    "udhcpc -i eth0<enter><wait2s>",	# Configure network via DHCP
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/answerfile<enter><wait>", # Download answerfile
    "echo \"root:vagrant\" | chpasswd<enter><wait>",
    "mkdir -p /etc/ssh/sshd_config.d<enter>",
    "echo \"PermitRootLogin yes\" > /etc/ssh/sshd_config.d/root.conf<enter>",
    "setup-apkrepos -1c<enter><wait3s>",
    "apk add sudo<enter><wait>",
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/fix_efiboot.sh<enter><wait>", # Download fixefiboot script
    "yes | setup-alpine -e -f answerfile<enter><wait45s>", 	# Run setup with answerfile
    "sh fixefiboot.sh<enter><wait3s>",
    "reboot<enter>"
]

# User/password for initial SSH
ssh_username = "root"
ssh_password = "vagrant"

# Execute command
execute_command = "{{.Vars}} sh -eux '{{.Path}}'"
# Reboot command
reboot_command = "reboot"
# Shutdown command
shutdown_command = "poweroff"

# Scripts to run after OS install
provision_scripts = ["alpine/3.20-base.sh"]
# Scripts to run before box bulding
cleanup_scripts = []
