box_name    = "ubuntu-24.04"

# Guest OS types
guest_os_type_vbox         = "Ubuntu_64"
guest_os_type_vmware_amd64 = "ubuntu-64"
guest_os_type_vmware_arm64 = "arm-ubuntu-64"

# Autoinstall configuration
http_directory = "http" # Contains user-data and meta-data
boot_command = [
  "<wait2s>",
  "c<wait>",     # Select boot command prompt
  "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/<enter><wait>",
  "<wait2s>",
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
