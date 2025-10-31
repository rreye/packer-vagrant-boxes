// File: packer/base_from_iso.pkr.hcl
// Master template for building Vagrant boxes from ISO files.
packer {
  required_plugins {
    virtualbox = { version = ">= 1.1.3", source = "github.com/hashicorp/virtualbox" }
    vmware     = { version = ">= 1.2.0", source = "github.com/hashicorp/vmware" }
    qemu       = { version = ">= 1.1.4", source = "github.com/hashicorp/qemu" }
  }
}

# --- 1. Input Variables ---
variable "box_name" { type = string }			# e.g., "ubuntu-24.04"
variable "box_version" { type = string }        	# e.g., "1.0.0"
variable "build_arch" { type = string }         	# Passed from workflow: "arm64" or "amd64"
variable "provision_scripts" { type = list(string) }	# List of shell scripts to run

# ISO specific variables
variable "iso_url_amd64" { type = string }
variable "iso_checksum_amd64" { type = string }
variable "iso_url_arm64" { type = string }
variable "iso_checksum_arm64" { type = string }
variable "http_directory" { type = string }     # Path to unattended install files (relative to var file)
variable "boot_command" { type = list(string) } # Keystrokes for unattended install boot
variable "ssh_username" { type = string }
variable "ssh_password" { type = string }
variable "shutdown_command" { type = string }   # Command to shut down the VM cleanly

# VM resource variables
variable "cpus" {
  type = number
  default = 2
}
variable "memory" {
  type = number
  default = 2048
}
variable "disk_size" {
  type = number
  default = 32768	# Disk size in MB (32GB default)
}

# Guest OS type variables (provider specific)
variable "guest_os_type_vbox" {
  type = string
  default = "Other_64"
}
variable "guest_os_type_vmware_amd64" {
  type = string
  default = "other-64"
}
variable "guest_os_type_vmware_arm64" {
  type = string
  default = "arm-other-64"
}

# --- 2. Local Variables ---
# (Helper variables derived from input)

locals {
  # Select ISO URL and checksum based on build_arch
  iso_url = var.build_arch == "arm64" ? var.iso_url_arm64 : var.iso_url_amd64
  iso_checksum = var.build_arch == "arm64" ? var.iso_checksum_arm64 : var.iso_checksum_amd64
  # Select VMware guest OS type based on build_arch
  guest_os_type_vmware = var.build_arch == "arm64" ? var.guest_os_type_vmware_arm64 : var.guest_os_type_vmware_amd64
}

# --- 3. Builders (Sources) ---
# One source block per provider and architecture combination.
# The name format provider.arch (e.g., "virtualbox-iso.amd64") is used by the workflow.

# --- VirtualBox ---
source "virtualbox-iso" "amd64" {
  guest_os_type      = var.guest_os_type_vbox
  iso_url            = local.iso_url
  iso_checksum       = local.iso_checksum
  http_directory     = var.http_directory
  boot_command       = var.boot_command
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "20m"
  ssh_read_write_timeout = "1m"
  output_directory   = "output-vbox-amd64"
  shutdown_command   = var.shutdown_command
  cpus               = var.cpus
  memory             = var.memory
  disk_size          = var.disk_size
  format             = "ova" # Required for vagrant post-processor
  headless           = false
  guest_additions_mode = "disable"
}

source "virtualbox-iso" "arm64" {
  guest_os_type      = var.guest_os_type_vbox
  iso_url            = local.iso_url
  iso_checksum       = local.iso_checksum
  http_directory     = var.http_directory
  boot_command       = var.boot_command
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "20m"
  ssh_read_write_timeout = "1m"
  output_directory   = "output-vbox-arm64"
  shutdown_command   = var.shutdown_command
  format             = "ova"
  headless           = true
  guest_additions_mode = "disable"
  vboxmanage         = [ # ARM specific settings
    ["modifyvm", "{{.Name}}", "--firmware", "efi"],
    ["modifyvm", "{{.Name}}", "--cpu-profile", "host"],
    ["modifyvm", "{{.Name}}", "--cpus", "${var.cpus}"],
    ["modifyvm", "{{.Name}}", "--memory", "${var.memory}"]
  ]
}

# --- VMware ---
source "vmware-iso" "amd64" {
  guest_os_type      = local.guest_os_type_vmware
  iso_url            = local.iso_url
  iso_checksum       = local.iso_checksum
  http_directory     = var.http_directory
  boot_command       = var.boot_command
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "20m"
  ssh_read_write_timeout = "1m"
  output_directory   = "output-vmware-amd64"
  shutdown_command   = var.shutdown_command
  cpus               = var.cpus
  memory             = var.memory
  disk_size          = var.disk_size
  format             = "vmx" # Required for vagrant post-processor
  headless           = false
  tools_upload_flavor = "linux"
}

source "vmware-iso" "arm64" {
  guest_os_type      = local.guest_os_type_vmware
  iso_url            = local.iso_url
  iso_checksum       = local.iso_checksum
  http_directory     = var.http_directory
  boot_command       = var.boot_command
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "20m"
  ssh_read_write_timeout = "1m"
  output_directory   = "output-vmware-arm64"
  shutdown_command   = var.shutdown_command
  cpus               = var.cpus
  memory             = var.memory
  disk_size          = var.disk_size
  format             = "vmx"
  firmware           = "efi" # Required for arm64
  headless           = true
  tools_upload_flavor = "linux"
}

# --- QEMU ---
source "qemu" "amd64" {
  iso_url            = local.iso_url
  iso_checksum       = local.iso_checksum
  http_directory     = var.http_directory
  boot_command       = var.boot_command
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "30m"
  output_directory   = "output-qemu-amd64"
  shutdown_command   = var.shutdown_command
  cpus               = var.cpus
  memory             = var.memory
  disk_size          = "${var.disk_size}M" # Qemu needs unit
  format             = "qcow2"
  accelerator        = "kvm" # Use KVM on Linux amd64 runner
  headless           = false
}

source "qemu" "arm64" {
  iso_url            = local.iso_url
  iso_checksum       = local.iso_checksum
  http_directory     = var.http_directory
  boot_command       = var.boot_command
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "20m"
  ssh_read_write_timeout = "1m"
  output_directory   = "output-qemu-arm64"
  shutdown_command   = var.shutdown_command
  cpus               = var.cpus
  memory             = var.memory
  disk_size          = "${var.disk_size}M"
  format             = "qcow2"
  accelerator        = "hvf" # Use HVF on macOS arm64 runner
  headless           = true
  # ARM specific settings
  machine_type       = "virt"
  cpu_model          = "cortex-a76"
}

# --- 4. Build Block (Provisioning) ---
build {
  # List all possible sources
  sources = [
    "source.virtualbox-iso.amd64",
    "source.virtualbox-iso.arm64",
    "source.vmware-iso.amd64",
    "source.vmware-iso.arm64",
    "source.qemu.amd64",
    "source.qemu.arm64"
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
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    scripts = ["${path.root}/scripts/vagrant.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- SSHD ---
  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    scripts = ["${path.root}/scripts/sshd.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- OS customization ---
  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    scripts = var.provision_scripts
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- Force reboot ---
  provisioner "shell" {
    pause_after = "1m"
    inline = ["echo Rebooting && echo 'vagrant' | sudo -S shutdown -rf now"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  # --- Provider specific ---
  provisioner "shell" {
    only = ["virtualbox-iso.amd64", "virtualbox-iso.arm64"]
    pause_before = "10s"
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    scripts = ["${path.root}/scripts/guest_tools_virtualbox.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  provisioner "shell" {
    only = ["vmware-iso.amd64", "source.vmware-iso.arm64"]
    pause_before = "10s"
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    scripts = ["${path.root}/scripts/guest_tools_vmware.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  provisioner "shell" {
    only = ["qemu.amd64", "qemu.arm64"]
    pause_before = "10s"
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    scripts = ["${path.root}/scripts/guest_tools_qemu.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- Force reboot ---
  provisioner "shell" {
    pause_after = "1m"
    inline = ["echo Rebooting && echo 'vagrant' | sudo -S shutdown -rf now"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- Cleanup ---
  provisioner "shell" {
    pause_before = "10s"
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    scripts = ["${path.root}/scripts/cleanup.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  # --- 5. Post-Processing ---
  # Create the Vagrant box file from the build artifact
  post-processor "vagrant" {
    # Apply to all builds defined in this template
    output = "${var.box_name}-${var.build_arch}-${var.box_version}_{{.Provider}}.box"
    compression_level = 9
    keep_input_artifact = false # Delete the intermediate VM files
  }
}
