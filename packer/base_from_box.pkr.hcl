// File: packer/base_from_box.pkr.hcl
// Master template for building Vagrant boxes from existing boxes.
packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.1.6"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

# --- 1. Input Variables ---
variable "box_name" { type = string }			# e.g., "ubuntu-24.04"
variable "box_version" { type = string }        	# e.g., "1.0.0"
variable "base_box" { type = string }        		# e.g., "bento/ubuntu-24.04"
variable "base_box_version" { type = string }        	# e.g., ">= 4.3.0"
variable "build_arch" { type = string }         	# Passed from workflow: "arm64" or "amd64"
variable "provision_scripts" { type = list(string) }	# List of shell scripts to run
variable "execute_command" { type = string }		# Command to execute provisioning scripts
variable "reboot_command" { type = string }		# Command to reboot the VM

# --- 2. Builder Definitions (Sources) ---
source "vagrant" "virtualbox" {
  source_path  = var.base_box
  box_version  = var.base_box_version
  provider     = "virtualbox"
  template     = "${path.root}/Vagrantfile.template"
  skip_add     = false
  add_force    = true
  communicator = "ssh"
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout        = "20m"
  ssh_read_write_timeout = "1m"
}

source "vagrant" "vmware" {
  source_path  = var.base_box
  box_version  = var.base_box_version
  provider     = "vmware_desktop" # This maps to VMware Fusion on macOS
  template     = "${path.root}/Vagrantfile.template"
  skip_add     = false
  add_force    = true
  communicator = "ssh"
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout        = "20m"
  ssh_read_write_timeout = "1m"
}

source "vagrant" "libvirt" {
  source_path  = var.base_box
  box_version  = var.base_box_version
  provider     = "libvirt" # This will use QEMU on the runner
  template     = "${path.root}/Vagrantfile.template"
  skip_add     = false
  add_force    = true
  communicator = "ssh"
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout        = "20m"
  ssh_read_write_timeout = "1m"
}

# --- 3. Build Block (Provisioning) ---
# This block applies to all 3 sources above
build {
  # List the 3 sources this build block controls
  sources = [
    "source.vagrant.virtualbox",
    "source.vagrant.vmware",
    "source.vagrant.libvirt"
  ]
  # Provisioning steps (common logic)
  provisioner "shell" {
    # Wait for SSH to be ready after OS install
    pause_before = "10s"
    inline = [
        "echo 'SSH is up. Starting provisioning...'"
    ]
  }

  # --- Vagrant user config ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/vagrant.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- SSHD ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/sshd.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- GRUB config ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/grub.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- OS customization ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = var.provision_scripts
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- Force reboot ---
  provisioner "shell" {
    pause_after = "30s"
    inline = [
      "echo 'Rebooting in background...'",
      "nohup ${var.reboot_command} &",
      "sleep 2"
    ]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  # --- Provider specific ---
  provisioner "shell" {
    only = ["vagrant.virtualbox"]
    pause_before = "10s"
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/guest_tools_virtualbox.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  # --- Force reboot ---
  provisioner "shell" {
    only = ["vagrant.virtualbox"]
    pause_after = "30s"
    inline = [
      "echo 'Rebooting in background...'",
      "nohup ${var.reboot_command} &",
      "sleep 2"
    ]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  provisioner "shell" {
    only = ["vagrant.vmware"]
    pause_before = "10s"
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/guest_tools_vmware.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  provisioner "shell" {
    only = ["vagrant.libvirt"]
    pause_before = "10s"
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/guest_tools_qemu.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- Cleanup ---
  provisioner "shell" {
    pause_before = "10s"
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/cleanup.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
}
