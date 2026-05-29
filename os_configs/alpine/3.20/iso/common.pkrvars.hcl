box_name = "alpine-3.20"

# Guest OS types
guest_os_type_vbox_amd64   = "Linux_64"    # Generic Linux
guest_os_type_vbox_arm64   = "Linux_arm64" # Generic Linux
guest_os_type_vmware_amd64 = "other-64"
guest_os_type_vmware_arm64 = "arm-other-64"
# UTM
utm_net_string = "utm_mode"

# Alpine Answer File setup
boot_command_amd64 = [
    "root<enter>",                # Login as root (no password initially)
    "ifconfig eth0 up; udhcpc -i eth0<enter><wait2s>",
    "ifconfig eth1 up; udhcpc -i eth1<enter><wait2s>",
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/setup.sh<enter><wait>",	# Download setup script
    "sh setup.sh {{ .HTTPIP }} {{ .HTTPPort }}<enter>"			# Run setup
]

boot_command_arm64 = [
    "root<enter>",                # Login as root (no password initially)
    "ifconfig eth0 up; udhcpc -i eth0<enter><wait2s>",
    "ifconfig eth1 up; udhcpc -i eth1<enter><wait2s>",
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/setup.sh<enter><wait>",	# Download setup script
    "sh setup.sh {{ .HTTPIP }} {{ .HTTPPort }}<enter>"			# Run setup
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
