box_name    = "ubuntu-24.04"

# Guest OS types
guest_os_type_vbox         = "Ubuntu_64"
guest_os_type_vmware_amd64 = "ubuntu-64"
guest_os_type_vmware_arm64 = "arm-ubuntu-64"

# Autoinstall configuration
http_directory = "http" # Contains user-data and meta-data
boot_command = [
  "<wait5s>",
  "c<wait>",     # Select boot command prompt
  "linux /casper/vmlinuz ip=dhcp autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ net.ifnames=0<enter><wait>",
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
provision_scripts = ["${path.root}/scripts/os/ubuntu/24.04-base.sh"]
