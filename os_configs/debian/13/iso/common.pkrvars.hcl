box_name = "debian-13"

# Guest OS types
guest_os_type_vbox_amd64   = "Debian_64"
guest_os_type_vbox_arm64   = "Debian_arm64"
guest_os_type_vmware_amd64 = "debian13-64"
guest_os_type_vmware_arm64 = "arm-debian13-64"

# Autoinstall preseed configuration
boot_command_amd64 = [
  "<wait5s>",
  "<esc><wait>",
  "auto priority=critical preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
  "debian-installer/language=es ",
  "debian-installer/locale=es_ES.UTF-8 ",
  "kbd-chooser/method=es ",
  "keyboard-configuration/keymap=es ",
  "netcfg/get_hostname={{ .Name }} ",
  "netcfg/get_domain=vagrantup.com ",
  "apt-setup/cdrom/set-first=false ", 
  "fb=false ",
  "console-setup/ask_detect=false ",
  "net.ifnames=0 biosdevname=0 ",
  "<enter><wait>"
]

boot_command_arm64 = [
  "<wait5s><up><wait>",
  "e",
  "<wait><down><down><down><end><wait>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "auto=true priority=critical preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
  "debian-installer/language=es ",
  "debian-installer/locale=es_ES.UTF-8 ",
  "kbd-chooser/method=es ",
  "keyboard-configuration/keymap=es ",
  "netcfg/get_hostname={{ .Name }} ",
  "netcfg/get_domain=vagrantup.com ",
  "apt-setup/cdrom/set-first=false ", 
  "fb=false ",
  "console-setup/ask_detect=false ",
  "net.ifnames=0 biosdevname=0 ",
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
provision_scripts = ["debian/13-base.sh"]
# Scripts to run before box bulding
cleanup_scripts = ["debian/cleanup_repos.sh"]
