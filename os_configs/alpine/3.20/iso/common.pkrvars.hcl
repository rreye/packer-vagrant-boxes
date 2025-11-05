box_name    = "alpine-3.20"

# Guest OS types
guest_os_type_vbox         = "Linux26_64" # Generic Linux
guest_os_type_vmware_amd64 = "other-64"
guest_os_type_vmware_arm64 = "arm-other-64"

# Alpine Answer File setup
http_directory = "http"
boot_command = [
    # Boot sequence for Alpine setup with answerfile via HTTP
    "root<enter>",                # Login as root (no password initially)
    "ifconfig eth0 up<enter><wait>",
    "udhcpc -i eth0<enter><wait2s>",	# Configure network via DHCP
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/answerfile<enter><wait>", # Download answerfile
    "echo \"root:vagrant\" | chpasswd<enter><wait>",
    "mkdir -p /etc/ssh/sshd_config.d<enter>",
    "echo \"PermitRootLogin yes\" > /etc/ssh/sshd_config.d/root.conf<enter>",
    "yes | setup-alpine -e -f answerfile<enter><wait30s>", 	# Run setup with answerfile
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
