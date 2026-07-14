box_name = "opensuse-leap-16"

# Guest OS types
guest_os_type_vbox_amd64   = "OpenSUSE_Leap_64"
guest_os_type_vbox_arm64   = "OpenSUSE_Leap_arm64"
guest_os_type_vmware_amd64 = "opensuse-64"
guest_os_type_vmware_arm64 = "arm-sles16-64"

# Kickstart configuration
boot_command_amd64 = [
    "<wait2s><down><wait>e<wait>",
    "<down><down><down><down><end><wait>",
    " inst.auto=http://{{ .HTTPIP }}:{{ .HTTPPort }}/agama-profile.json", # Add profile URL parameter
    " net.ifnames=0 biosdevname=0", # Consistent network names
    "<wait><leftCtrlOn><wait>x<wait><leftCtrlOff>" # Start boot
]

boot_command_arm64 = [
    "<wait2s>e<wait>",
    "<down><down><down><down><end><wait>",
    " inst.auto=http://{{ .HTTPIP }}:{{ .HTTPPort }}/agama-profile.json", # Add profile URL parameter
    " net.ifnames=0 biosdevname=0", # Consistent network names
    "<wait><leftCtrlOn><wait>x<wait><leftCtrlOff>" # Start boot
]

# Execute command
execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
# Reboot command
reboot_command = "echo 'vagrant' | sudo -S shutdown -rf now"
# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S /sbin/halt -h -p"

# Scripts to run after OS install
provision_scripts = ["opensuse-leap/16-base.sh"]
# Scripts to run before box bulding
cleanup_scripts = []
