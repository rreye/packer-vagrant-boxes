box_name = "rocky-10"

# Guest OS types
guest_os_type_vbox_amd64   = "RedHat10_64"
guest_os_type_vbox_arm64   = "RedHat10_arm64"
guest_os_type_vmware_amd64 = "rhel10-64"
guest_os_type_vmware_arm64 = "arm-rhel10-64"

# Kickstart configuration
boot_command_amd64 = [
    "<wait2s><up><wait>", # Interrupt bootloader
    "e",
    "<wait><down><down><end><wait>",
    " inst.text",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg", # Add Kickstart URL parameter
    " net.ifnames=0 biosdevname=0", # Consistent network names
    "<enter><wait>" # Start boot
]

boot_command_arm64 = [
    "<wait2s><up><wait>", # Interrupt bootloader
    "e",
    "<wait><down><down><end><wait>",
    " inst.text",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg", # Add Kickstart URL parameter
    " net.ifnames=0 biosdevname=0", # Consistent network names
    " console=tty0", # Required for QEMU 'virt' board to show boot logs on the VNC/Cocoa screen (defaults to serial otherwise)
    "<wait><f10>" # Start boot
]

# Execute command
execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
# Reboot command
reboot_command = "echo 'vagrant' | sudo -S shutdown -rf now"
# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S /sbin/halt -h -p"

# Scripts to run after OS install
provision_scripts = ["rocky/9-base.sh"]
# Scripts to run before box bulding
cleanup_scripts = []
