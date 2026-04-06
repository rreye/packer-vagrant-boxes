box_name         = "omv7"
box_version      = "1.2"

// Base box used
base_box         = "rreye/debian-12"
base_box_version = "20260302"

# Execute command
execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
# Reboot command
reboot_command = "echo 'vagrant' | sudo -S shutdown -rf now"
# Shutdown command
shutdown_command = "echo 'vagrant' | sudo -S shutdown -h now"

box_provision_scripts = ["scripts/install-omv7.sh"]
