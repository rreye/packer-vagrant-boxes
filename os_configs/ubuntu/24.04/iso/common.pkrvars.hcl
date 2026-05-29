box_name = "ubuntu-24.04"

# Guest OS types
guest_os_type_vbox_amd64   = "Ubuntu_64"
guest_os_type_vbox_arm64   = "Ubuntu_arm64"
guest_os_type_vmware_amd64 = "ubuntu-64"
guest_os_type_vmware_arm64 = "arm-ubuntu-64"

# Autoinstall configuration
boot_command_amd64 = [
  "<wait2s>",
  "c<wait>",     # Select boot command prompt
  "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
  "net.ifnames=0 biosdevname=0", # Consistent network names
  "<enter><wait2s>"
  "initrd /casper/initrd<enter><wait>",
  "boot<enter><wait>"
]

boot_command_arm64 = [
  "<wait2s>",
  "c<wait>",     # Select boot command prompt
  "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
  "net.ifnames=0 biosdevname=0 ", # Consistent network names
  "console=tty0 ", # Required for QEMU 'virt' board to show boot logs on the VNC/Cocoa screen (defaults to serial otherwise)
  "<enter><wait2s>"
  "initrd /casper/initrd<enter><wait>",
  "boot<enter><wait>"
]

# Execute command
execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
# Reboot command
reboot_command = "echo 'vagrant' | sudo -S shutdown -rf now"
# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S shutdown -h now"

# Scripts to run after OS install
provision_scripts = ["ubuntu/24.04-base.sh"]
# Scripts to run before box bulding
cleanup_scripts = []
