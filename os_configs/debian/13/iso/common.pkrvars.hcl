box_name    = "debian-13"

# Guest OS types
guest_os_type_vbox_amd64   = "Debian_64"
guest_os_type_vbox_arm64   = "Debian_arm64"
guest_os_type_vmware_amd64 = "debian13-64"
guest_os_type_vmware_arm64 = "arm-debian13-64"

# Autoinstall preseed configuration
http_directory = "http"
boot_command_amd64 = [
  "<wait5s>",
  "<esc><wait>",
  "auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg netcfg/get_hostname={{ .Name }}<enter><wait>"
]

boot_command_arm64 = [
  "<wait5s>",
"<wait>e<wait><down><down><down><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><wait>",
  "install <wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg netcfg/get_hostname={{ .Name }} netcfg/get_domain=vagrantup.com debian-installer=en_US.UTF-8 locale=en_US.UTF-8 kbd-chooser/method=us keyboard-configuration/xkb-keymap=us debconf/frontend=noninteractive console-setup/ask_detect=false console-keymaps-at/keymap=us fb=false grub-installer/bootdev=default<wait><f10><wait>"
]

# Execute command
execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
# Reboot command
reboot_command = "echo 'vagrant' | sudo -S shutdown -rf now"
# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S shutdown -h now"

# Scripts to run after OS install
provision_scripts = ["debian/13-base.sh"]
