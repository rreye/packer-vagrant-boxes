box_name    = "ubuntu-22.04"

# Guest OS types
guest_os_type_vbox_amd64   = "Ubuntu_64"
guest_os_type_vbox_arm64   = "Ubuntu_arm64"
guest_os_type_vmware_amd64 = "ubuntu-64"
guest_os_type_vmware_arm64 = "arm-ubuntu-64"

# Autoinstall configuration
http_directory = "http" # Contains user-data and meta-data
boot_command_amd64 = [
  "<wait2s>",
  "c<wait>",     # Select boot command prompt
  "linux /casper/hwe-vmlinuz autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/<enter><wait>",
  "<wait2s>",
  "initrd /casper/hwe-initrd<enter><wait>",
  "boot<enter><wait>"
]

boot_command_arm64 = [
  "<wait2s>",
  "c<wait>",     # Select boot command prompt
  "linux /casper/hwe-vmlinuz autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/<enter><wait>",
  "<wait2s>",
  "initrd /casper/hwe-initrd<enter><wait>",
  "boot<enter><wait>"
]

# Execute command
execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
# Reboot command
reboot_command = "echo 'vagrant' | sudo -S shutdown -rf now"
# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S shutdown -h now"

# Scripts to run after OS install
provision_scripts = ["ubuntu/22.04-base.sh"]
