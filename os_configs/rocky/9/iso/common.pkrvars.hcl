box_name    = "rocky-9"

# Guest OS types
guest_os_type_vbox         = "RedHat_64"
guest_os_type_vmware_amd64 = "rhel9-64"
guest_os_type_vmware_arm64 = "arm-rhel9-64"

# Kickstart configuration
http_directory = "http"
boot_command = [
    "<wait2s><up><wait><tab>", # Interrupt bootloader
    " inst.text",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg", # Add Kickstart URL parameter
    " net.ifnames=0 biosdevname=0", # Consistent network names
    "<enter><wait>" # Start boot
]

# Execute command
execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
# Reboot command
reboot_command = "echo 'vagrant' | sudo -S shutdown -rf now"
# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S /sbin/halt -h -p"

# Scripts to run after OS install
provision_scripts = ["${path.root}/scripts/os/rocky/9-base.sh"]
