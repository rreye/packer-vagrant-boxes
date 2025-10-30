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
  ssh_timeout  = "20m"
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
  ssh_timeout  = "20m"
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
  ssh_timeout  = "20m"
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

  # --- Customization ---
  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E /bin/bash '{{.Path}}'"
    scripts = var.provision_scripts
    expect_disconnect = true
    timeout         = "30m"
  }
}
