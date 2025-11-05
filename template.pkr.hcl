// File: packer/template.pkr.hcl
// Master template for building Vagrant boxes from ISO files and/or existing boxes.
packer {
  required_plugins {
    virtualbox = { version = ">= 1.1.3", source = "github.com/hashicorp/virtualbox" }
    vmware     = { version = ">= 1.2.0", source = "github.com/hashicorp/vmware" }
    qemu       = { version = ">= 1.1.4", source = "github.com/hashicorp/qemu" }
    vagrant    = { version = ">= 1.1.6", source = "github.com/hashicorp/vagrant" }
  }
}

# --- 1. Input variables ---

# --- 1. Common variables ---
variable "box_name" { type = string }		# e.g., "ubuntu-24.04"
variable "box_version" { type = string }        # e.g., "1.0.0"
variable "execute_command" { type = string }	# Command to execute provisioning scripts
variable "shutdown_command" { type = string }   # Command to shut down the VM cleanly
variable "reboot_command" { type = string }	# Command to reboot the VM


variable "boot_wait" {
  type = string
  default = "20s"
}

variable "provision_scripts" {
  type = list(string)
  default = []
}

variable "ssh_username" {
  type    = string
  default = "vagrant"
}
variable "ssh_password" {
  type    = string
  default = "vagrant"
}

# --- 1. Variables "Box-only" ---
variable "base_box" { 
  type    = string
  default = null
}
variable "base_box_version" {
  type    = string
  default = null
}
variable "box_provision_scripts" {
  type = list(string)
  default = []
}

# --- 1. Variables "ISO-only" ---
variable "build_arch" {
  type    = string
  default = null
}

variable "iso_url_amd64" {
  type    = string
  default = null
}
variable "iso_checksum_amd64" {
  type    = string
  default = null
}
variable "iso_url_arm64" {
  type    = string
  default = null
}
variable "iso_checksum_arm64" {
  type    = string
  default = null
}
variable "http_directory" {
  type    = string
  default = null
}
variable "boot_command" {
  type    = list(string)
  default = null
}
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

# --- 1. Guest OS type variables (provider specific) ---
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
  raw_checksum = var.build_arch == "arm64" ? var.iso_checksum_arm64 : var.iso_checksum_amd64
  parts = (local.raw_checksum == null || local.raw_checksum == "") ? [] : split(":", local.raw_checksum)
  iso_checksum = length(local.parts) == 0 ? "none" : (length(local.parts) == 2 ? local.parts[1] : local.raw_checksum)
  # Select VMware guest OS type based on build_arch
  guest_os_type_vmware = var.build_arch == "arm64" ? var.guest_os_type_vmware_arm64 : var.guest_os_type_vmware_amd64
}

# --- 3. Builders (Sources) ---
# --- VirtualBox ---
source "vagrant" "virtualbox" {
  source_path  = var.base_box == null ? "dummy" : var.base_box
  box_version  = var.base_box_version == null ? "0" : var.base_box_version
  provider     = "virtualbox"
  template     = "${path.root}/Vagrantfile.template"
  skip_add     = false
  add_force    = true
  communicator = "ssh"
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
  ssh_read_write_timeout = "1m"
}

source "virtualbox-iso" "amd64" {
  firmware           = "bios"
  guest_os_type      = var.guest_os_type_vbox
  iso_url            = local.iso_url == null ? "dummy" : local.iso_url
  iso_checksum       = local.iso_checksum
  http_directory     = var.http_directory
  boot_command       = var.boot_command
  boot_wait          = var.boot_wait
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "20m"
  ssh_read_write_timeout = "1m"
  output_directory   = "output-vbox-amd64"
  shutdown_command   = var.shutdown_command
  cpus               = var.cpus
  memory             = var.memory
  disk_size          = var.disk_size
  hard_drive_interface = "sata"
  iso_interface      = "sata"
  format             = "ova" # Required for vagrant post-processor
  headless           = true
  guest_additions_mode = "disable"
  vboxmanage         = [ # ARM specific settings
    ["modifyvm", "{{.Name}}", "--chipset", "ich9"],
    ["modifyvm", "{{.Name}}", "--audio-enabled", "off"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
    ["modifyvm", "{{.Name}}", "--cableconnected1", "on"],
  ]
}

source "virtualbox-iso" "arm64" {
  firmware           = "efi"
  guest_os_type      = var.guest_os_type_vbox
  iso_url            = local.iso_url == null ? "dummy" : local.iso_url
  iso_checksum       = local.iso_checksum
  http_directory     = var.http_directory
  boot_command       = var.boot_command
  boot_wait          = var.boot_wait
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "20m"
  ssh_read_write_timeout = "1m"
  output_directory   = "output-vbox-arm64"
  shutdown_command   = var.shutdown_command
  cpus               = var.cpus
  memory             = var.memory
  disk_size          = var.disk_size
  hard_drive_interface = "virtio"
  iso_interface      = "virtio"
  format             = "ova"
  headless           = true
  guest_additions_mode = "disable"
  vboxmanage         = [ # ARM specific settings
    ["modifyvm", "{{.Name}}", "--chipset", "armv8virtual"],
    ["modifyvm", "{{.Name}}", "--audio-enabled", "off"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
    ["modifyvm", "{{.Name}}", "--cableconnected1", "on"],
    ["modifyvm", "{{.Name}}", "--graphicscontroller", "qemuramfb"],
  ]
}

# --- VMware ---
source "vagrant" "vmware" {
  source_path  = var.base_box == null ? "dummy" : var.base_box
  box_version  = var.base_box_version == null ? "0" : var.base_box_version
  provider     = "vmware_desktop" # This maps to VMware Fusion on macOS
  template     = "${path.root}/Vagrantfile.template"
  skip_add     = false
  add_force    = true
  communicator = "ssh"
  ssh_username = var.ssh_password
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
  ssh_read_write_timeout = "1m"
}

source "vmware-iso" "amd64" {
  firmware           = "bios"
  guest_os_type      = local.guest_os_type_vmware
  iso_url            = local.iso_url == null ? "dummy" : local.iso_url
  iso_checksum       = local.iso_checksum
  http_directory     = var.http_directory
  boot_command       = var.boot_command
  boot_wait          = var.boot_wait
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
  headless           = true
}

source "vmware-iso" "arm64" {
  firmware           = "efi"
  guest_os_type      = local.guest_os_type_vmware
  iso_url            = local.iso_url == null ? "dummy" : local.iso_url
  iso_checksum       = local.iso_checksum
  http_directory     = var.http_directory
  boot_command       = var.boot_command
  boot_wait          = var.boot_wait
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
  headless           = true
}

# --- QEMU ---
source "vagrant" "libvirt" {
  source_path  = var.base_box == null ? "dummy" : var.base_box
  box_version  = var.base_box_version == null ? "0" : var.base_box_version
  provider     = "libvirt" # This will use QEMU on the runner
  template     = "${path.root}/Vagrantfile.template"
  skip_add     = false
  add_force    = true
  communicator = "ssh"
  ssh_username = var.ssh_password
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
  ssh_read_write_timeout = "1m"
}

source "qemu" "amd64" {
  iso_url            = local.iso_url == null ? "dummy" : local.iso_url
  iso_checksum       = local.iso_checksum
  http_directory     = var.http_directory
  boot_command       = var.boot_command
  boot_wait          = var.boot_wait
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "20m"
  output_directory   = "output-qemu-amd64"
  shutdown_command   = var.shutdown_command
  cpus               = var.cpus
  memory             = var.memory
  disk_size          = "${var.disk_size}M" # Qemu needs unit
  disk_compression   = "true"
  disk_detect_zeroes = "unmap"
  disk_discard       = "unmap"  
  format             = "qcow2"
  accelerator        = "kvm" # Use KVM on Linux amd64 runner
  headless           = true
  use_default_display = false
  # AMD64 specific settings
  machine_type       = "q35"
  cpu_model          = "host"
}

source "qemu" "arm64" {
  iso_url            = local.iso_url == null ? "dummy" : local.iso_url
  iso_checksum       = local.iso_checksum
  http_directory     = var.http_directory
  boot_command       = var.boot_command
  boot_wait          = var.boot_wait
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "20m"
  ssh_read_write_timeout = "1m"
  output_directory   = "output-qemu-arm64"
  shutdown_command   = var.shutdown_command
  cpus               = var.cpus
  memory             = var.memory
  disk_size          = "${var.disk_size}M"
  disk_compression   = "true"
  disk_detect_zeroes = "unmap"
  disk_discard       = "unmap"  
  format             = "qcow2"
  accelerator        = "hvf" # Use HVF on macOS arm64 runner
  headless           = true
  use_default_display = false
  # ARM specific settings
  machine_type       = "virt"
  cpu_model          = "cortex-a76"
}

# --- 4. Build Block (Provisioning) ---
build {
  # List all possible sources
  sources = [
    # ISO
    "source.virtualbox-iso.amd64",
    "source.virtualbox-iso.arm64",
    "source.vmware-iso.amd64",
    "source.vmware-iso.arm64",
    "source.qemu.amd64",
    "source.qemu.arm64",
    # BOX
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
    scripts = ["${path.root}/scripts/common/vagrant.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- SSHD ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/common/sshd.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- GRUB config ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/common/grub.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  # --- OS customization ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = length(var.provision_scripts) > 0 ? [for script_path in var.provision_scripts : "${path.root}/scripts/${script_path}"] : ["${path.root}/scripts/common/noop.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- Box customization ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = length(var.box_provision_scripts) > 0 ? var.box_provision_scripts : ["${path.root}/scripts/common/noop.sh"]
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
    only = ["virtualbox-iso.amd64", "virtualbox-iso.arm64", "vagrant.virtualbox"]
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/common/guest_tools_virtualbox.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- Force reboot ---
  provisioner "shell" {
    only = ["virtualbox-iso.amd64", "virtualbox-iso.arm64", "vagrant.virtualbox"]
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
    only = ["vmware-iso.amd64", "vmware-iso.arm64", "vagrant.vmware"]
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/common/guest_tools_vmware.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  provisioner "shell" {
    only = ["qemu.amd64", "qemu.arm64", "vagrant.libvirt"]
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/common/guest_tools_qemu.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- Cleanup ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/common/cleanup.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  # --- 5. Post-Processing ---
  # Create the Vagrant box file from the build artifact
  post-processor "vagrant" {
    except = ["vagrant.virtualbox", "vagrant.vmware", "vagrant.libvirt"]
    output = "${var.box_name}-${var.build_arch}-${var.box_version}_{{.Provider}}.box"
    compression_level = 9
    keep_input_artifact = false # Delete the intermediate VM files
  }
}
