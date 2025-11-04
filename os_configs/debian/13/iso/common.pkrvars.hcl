box_name    = "debian-13"

# Guest OS types
guest_os_type_vbox         = "Debian_64"
guest_os_type_vmware_amd64 = "debian13-64"
guest_os_type_vmware_arm64 = "arm-debian13-64"

# Autoinstall preseed configuration
http_directory = "http"
boot_command = [
  "<wait5s>",
  "<esc><wait>",
  "auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg netcfg/get_hostname={{ .Name }}<enter><wait>"
]

# Execute command
execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
# Reboot command
reboot_command = "echo 'vagrant' | sudo -S shutdown -rf now"
# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S shutdown -h now"

# Scripts to run after OS install
provision_scripts = ["debian/13-base.sh"]
