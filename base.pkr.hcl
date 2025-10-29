packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.1.6"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

# --- 1. Variables ---
variable "box_name" {
  type    = string
  description = "The name of the box"
}

variable "box_version" {
  type    = string
  description = "The version of the box"
}

variable "base_box" {
  type    = string
  description = "Base box on Vagrant Cloud"
}

variable "base_box_version" {
  type    = string
  default = "Base box version required, e.g. >= 4.3.0"
}

variable "provision_scripts" {
  type    = list(string)
  description = "List of provisioning scripts to be executed, related to the box directory"
}

variable "build_arch" {
  type    = string
  default = "amd64" # Default if not specified
}

# --- 2. Builder Definitions (Sources) ---
source "vagrant" "vagrant-vbox" {
  source_path  = var.base_box
  box_version  = var.base_box_version
  provider     = "virtualbox"
  output       = "${var.box_name}-${var.build_arch}-${var.box_version}_virtualbox.box"
  template     = "./Vagrantfile.template"
  ssh_username = "vagrant"
  ssh_timeout  = "20m"
}

source "vagrant" "vagrant-vmware" {
  source_path  = var.base_box
  box_version  = var.base_box_version
  provider     = "vmware_desktop" # This maps to VMware Fusion on macOS
  output       = "${var.box_name}-${var.build_arch}-${var.box_version}_vmware.box"
  template     = "./Vagrantfile.template"
  ssh_username = "vagrant"
  ssh_timeout  = "20m"
}

source "vagrant" "vagrant-libvirt" {
  source_path  = var.base_box
  box_version  = var.base_box_version
  provider     = "libvirt" # This will use QEMU on the runner
  output       = "${var.box_name}-${var.build_arch}-${var.box_version}_libvirt.box"
  template     = "./Vagrantfile.template"
  ssh_username = "vagrant"
  ssh_timeout  = "20m"
}

# --- 3. Build Block (Provisioning) ---
# This block applies to all 3 sources above
build {
  # List the 3 sources this build block controls
  sources = [
    "source.vagrant.vagrant-vbox",
    "source.vagrant.vagrant-vmware",
    "source.vagrant.vagrant-libvirt"
  ]

  # --- This is where you do your customization ---
  provisioner "shell" {
    execute_command = "{{.Vars}} /bin/bash '{{.Path}}'"
    scripts = var.provision_scripts
    expect_disconnect = true
    timeout         = "15m"
  }
}
