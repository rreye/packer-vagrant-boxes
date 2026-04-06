box_name         = "omv8"
box_version      = "1.0"

// Base box used
base_box         = "rreye/debian-13"
base_box_version = "20260304"

# Execute command
execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
# Reboot command
reboot_command = "echo 'vagrant' | sudo -S shutdown -rf now"
# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S shutdown -h now"

box_provision_scripts = ["scripts/install-omv8.sh", "scripts/finish-omv8-install.sh"]
