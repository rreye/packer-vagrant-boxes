// File: box/ubuntu-24.04/box.pkrvars.hcl
box_name         = "ubuntu-24.04"
box_version      = "1.0.0"
base_box         = "bento/ubuntu-24.04"
base_box_version = "202510.26.0"

# Execute command
execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"

# Reboot command
reboot_command = "echo 'vagrant' | sudo -S shutdown -rf now"

# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S shutdown -h now"

provision_scripts = ["scripts/provision-ubuntu.sh"]
