box_name = "debian-12"

# Guest OS types
guest_os_type_vbox_amd64   = "Debian_64"
guest_os_type_vbox_arm64   = "Debian_arm64"
guest_os_type_vmware_amd64 = "debian12-64"
guest_os_type_vmware_arm64 = "arm-debian12-64"

# Autoinstall preseed configuration
bboot_command_amd64 = [
  "<wait2s>",
  "<esc><wait>",
  "auto priority=critical preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
  "debian-installer/locale=en_GB.UTF-8 ",
  "apt-setup/cdrom/set-first=false ", 
  "console-setup/ask_detect=false ",
  "net.ifnames=0 biosdevname=0 ",
  "<enter><wait>"
]

boot_command_arm64 = [
  "<wait2s><up><wait>",
  "e",
  "<wait><down><down><down><end><wait>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "auto priority=critical preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
  "debian-installer/locale=en_GB.UTF-8 ",
  "apt-setup/cdrom/set-first=false ", 
  "console-setup/ask_detect=false ",
  "net.ifnames=0 biosdevname=0 ",
  "console=tty0", # Required for QEMU 'virt' board to show boot logs on the VNC/Cocoa screen (defaults to serial otherwise)
  "<wait>",
  "<f10>",
]

# Execute command
execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
# Reboot command
reboot_command = "echo 'vagrant' | sudo -S shutdown -rf now"
# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S shutdown -h now"

# Scripts to run after OS install
provision_scripts = ["debian/12-base.sh"]
# Scripts to run before box bulding
cleanup_scripts = ["debian/cleanup_repos.sh"]
