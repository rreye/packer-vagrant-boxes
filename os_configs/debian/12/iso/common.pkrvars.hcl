box_name    = "debian-12"

# Guest OS types
guest_os_type_vbox_amd64   = "Debian_64"
guest_os_type_vbox_arm64   = "Debian_arm64"
guest_os_type_vmware_amd64 = "debian12-64"
guest_os_type_vmware_arm64 = "arm-debian12-64"

# Autoinstall preseed configuration
http_directory = "http"
boot_command_amd64 = [
  "<wait5s>",
  "<esc><wait>",
  "auto ",
  "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
  "debian-installer=es_ES.UTF-8 ",
  "locale=es_ES.UTF-8 ",
  "kbd-chooser/method=es ",
  "keyboard-configuration/xkb-keymap=es ",
  "netcfg/get_hostname={{ .Name }} ",
  "netcfg/get_domain=vagrantup.com ",
  "apt-setup/cdrom/set-first=false ", 
  "fb=false ",
  "debconf/frontend=noninteractive ",
  "console-setup/ask_detect=false ",
  "<enter><wait>"
]

boot_command_arm64 = [
  "<wait5s>",
  "c",
  "<wait>",
  "linux /install.a64/vmlinuz auto=true priority=critical ",
  "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
  "debian-installer=en_US.UTF-8 ",
  "locale=en_US.UTF-8 ",
  "kbd-chooser/method=es ",
  "keyboard-configuration/xkb-keymap=es ",
  "netcfg/get_hostname={{ .Name }} ",
  "netcfg/get_domain=vagrantup.com ",
  "apt-setup/cdrom/set-first=false ",
  "fb=false ",
  "debconf/frontend=noninteractive ",
  "console-setup/ask_detect=false ",
  "--- <enter>",  
  "<wait>",
  "initrd /install.a64/initrd.gz<enter>",
  "<wait>",
  "boot<enter>"
]

# Execute command
execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
# Reboot command
reboot_command = "echo 'vagrant' | sudo -S shutdown -rf now"
# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S shutdown -h now"

# Scripts to run after OS install
provision_scripts = ["debian/12-base.sh"]
