// File: packer/template.pkr.hcl
// Master template for building Vagrant boxes from ISO files and/or existing boxes.
packer {
  required_plugins {
    virtualbox = { version = ">= 1.1.4", source = "github.com/hashicorp/virtualbox" }
    vmware     = { version = "= 2.1.3", source = "github.com/hashicorp/vmware" }
    qemu       = { version = ">= 1.1.5", source = "github.com/hashicorp/qemu" }
    utm        = { version = ">= v4.0.0", source  = "github.com/naveenrajm7/utm"}
    vagrant    = { version = ">= 1.1.7", source = "github.com/hashicorp/vagrant" }
  }
}

# --- 1. Input variables ---

# --- 1. Common variables ---
variable "box_name" { type = string }		# e.g., "ubuntu-24.04"
variable "box_version" { type = string }        # e.g., "1.0.0"
variable "build_arch" { type = string }         # e.g., "amd64"
variable "execute_command" { type = string }	# Command to execute provisioning scripts
variable "shutdown_command" { type = string }   # Command to shut down the VM cleanly
variable "reboot_command" { type = string }	# Command to reboot the VM

variable "boot_wait" {
  type = string
  default = "10s"
}

variable "provision_scripts" {
  type = list(string)
  default = []
}

variable "cleanup_scripts" {
  type = list(string)
  default = []
}

variable "provision_version_scripts" {
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
  default = "http"
}
variable "boot_command_amd64" {
  type    = list(string)
  default = null
}
variable "boot_command_arm64" {
  type    = list(string)
  default = null
}
variable "cpus" {
  type = number
  default = 1
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
variable "guest_os_type_vbox_amd64" {
  type = string
  default = "Other_64"
}
variable "guest_os_type_vbox_arm64" {
  type = string
  default = "Other_arm64"
}
variable "guest_os_type_vmware_amd64" {
  type = string
  default = "other-64"
}
variable "guest_os_type_vmware_arm64" {
  type = string
  default = "arm-other-64"
}

# --- 1. UTM variables (provider specific) ---
variable "build_utm" {
  type    = bool
  default = false
}

# --- 2. Local Variables ---
# (Helper variables derived from input)
locals {
  # Select ISO URL and checksum based on build_arch
  iso_url = var.build_arch == "arm64" ? var.iso_url_arm64 : var.iso_url_amd64
  raw_checksum = var.build_arch == "arm64" ? var.iso_checksum_arm64 : var.iso_checksum_amd64
  parts = (local.raw_checksum == null || local.raw_checksum == "") ? [] : split(":", local.raw_checksum)
  iso_checksum = length(local.parts) == 0 ? "none" : (length(local.parts) == 2 ? local.parts[1] : local.raw_checksum)

  base_dir = "${path.cwd}/${var.http_directory}"
  
  # Scan static files and serves them as is
  static_files = {
    for f in fileset(local.base_dir, "**/*") :
    "/${f}" => file("${local.base_dir}/${f}")
    if !endswith(f, ".pkrtpl.hcl")
  }

  # Scan the templates, renderized them, removes the .pkrtpl.hcl extension before serving them
  template_files = {
    for f in fileset(local.base_dir, "**/*.pkrtpl.hcl") :
    "/${replace(f, ".pkrtpl.hcl", "")}" => templatefile("${local.base_dir}/${f}", { is_utm = var.build_utm })
  }

  # Mandatory to prevent Cloud-init from failing
  ubuntu_meta_data = { 
    "/meta-data" = "" 
  }
  
  # Merge everything into the final map
  http_content_dynamic = merge(local.static_files, local.template_files, local.ubuntu_meta_data)
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
  guest_os_type      = var.guest_os_type_vbox_amd64
  iso_url            = local.iso_url == null ? "dummy" : local.iso_url
  iso_checksum       = local.iso_checksum
  http_content       = local.http_content_dynamic
  boot_command       = var.boot_command_amd64
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
  format             = "ova"
  headless           = false
  guest_additions_mode = "disable"
  gfx_controller     = "vmsvga"
  gfx_vram_size      = "32"
  vboxmanage         = [ # AMD64 specific settings
    ["modifyvm", "{{.Name}}", "--audio-enabled", "off"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
    ["modifyvm", "{{.Name}}", "--cableconnected1", "on"],
    ["modifyvm", "{{.Name}}", "--vrde", "off"],
    ["storagectl", "{{.Name}}", "--name", "IDE Controller", "--remove"],
  ]
}

source "virtualbox-iso" "arm64" {
  firmware           = "efi"
  guest_os_type      = var.guest_os_type_vbox_arm64
  iso_url            = local.iso_url == null ? "dummy" : local.iso_url
  iso_checksum       = local.iso_checksum
  http_content       = local.http_content_dynamic
  boot_command       = [ for cmd in var.boot_command_arm64 : cmd == "<NET_IFACE> " ? "" : cmd ]
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
  headless           = false
  guest_additions_mode = "disable"
  gfx_controller     = "vmsvga"
  gfx_vram_size      = "32"
  vboxmanage         = [ # ARM specific settings
    ["modifyvm", "{{.Name}}", "--chipset", "armv8virtual"],
    ["modifyvm", "{{.Name}}", "--audio-enabled", "off"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
    ["modifyvm", "{{.Name}}", "--cableconnected1", "on"],
    ["modifyvm", "{{.Name}}", "--vrde", "off"],
    ["modifyvm", "{{.Name}}", "--mouse", "usb"],
    ["modifyvm", "{{.Name}}", "--keyboard", "usb"],
    ["modifyvm", "{{.Name}}", "--usb-ohci", "off"],
    ["modifyvm", "{{.Name}}", "--usb-ehci", "off"],
    ["modifyvm", "{{.Name}}", "--usb-xhci", "on"],
    ["storagectl", "{{.Name}}", "--name", "IDE Controller", "--remove"],
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
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
  ssh_read_write_timeout = "1m"
}

source "vmware-iso" "amd64" {
  firmware           = "bios"
  guest_os_type      = var.guest_os_type_vmware_amd64
  iso_url            = local.iso_url == null ? "dummy" : local.iso_url
  iso_checksum       = local.iso_checksum
  http_content       = local.http_content_dynamic
  boot_command       = var.boot_command_amd64
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
  disk_adapter_type  = "sata"
  usb                = true
  network_adapter_type = "e1000e"
  vmx_remove_ethernet_interfaces = true
  format             = "vmx"
  headless           = false
}

source "vmware-iso" "arm64" {
  firmware           = "efi"
  guest_os_type      = var.guest_os_type_vmware_arm64
  iso_url            = local.iso_url == null ? "dummy" : local.iso_url
  iso_checksum       = local.iso_checksum
  http_content       = local.http_content_dynamic
  boot_command       = [ for cmd in var.boot_command_arm64 : cmd == "<NET_IFACE> " ? "" : cmd ]
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
  disk_adapter_type  = "sata"
  usb                = true
  network_adapter_type = "e1000e"
  vmx_remove_ethernet_interfaces = true
  format             = "vmx"
  headless           = false
}

# --- QEMU / Libvirt ---
source "vagrant" "libvirt" {
  source_path  = var.base_box == null ? "dummy" : var.base_box
  box_version  = var.base_box_version == null ? "0" : var.base_box_version
  provider     = "libvirt"
  template     = "${path.root}/Vagrantfile.template"
  skip_add     = false
  add_force    = true
  communicator = "ssh"
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
  ssh_read_write_timeout = "1m"
}

source "qemu" "amd64" {
  iso_url            = local.iso_url == null ? "dummy" : local.iso_url
  iso_checksum       = local.iso_checksum
  http_content       = local.http_content_dynamic
  boot_command       = var.boot_command_amd64
  boot_wait          = var.boot_wait
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "20m"
  output_directory   = "output-qemu-amd64"
  shutdown_command   = var.shutdown_command
  cpus               = var.cpus
  memory             = var.memory
  disk_size          = "${var.disk_size}M" # Qemu needs unit
  disk_compression   = true
  disk_detect_zeroes = "unmap"
  disk_discard       = "unmap"
  disk_interface     = "virtio"
  disk_cache         = "unsafe"
  format             = "qcow2"
  headless           = true
  use_default_display = false
  # AMD64 specific settings
  qemu_binary        = "qemu-system-x86_64"
  accelerator        = "kvm" # Use KVM on Linux amd64
  display            = "vnc=127.0.0.1:1"
  machine_type       = "q35"
  cpu_model          = "host"
  efi_boot           = false
}

source "qemu" "arm64" {
  iso_url            = local.iso_url == null ? "dummy" : local.iso_url
  iso_checksum       = local.iso_checksum
  http_content       = local.http_content_dynamic
  boot_command       = [ for cmd in var.boot_command_arm64 : cmd == "<NET_IFACE> " ? "" : cmd ]
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
  disk_compression   = true
  disk_detect_zeroes = "unmap"
  disk_discard       = "unmap"
  disk_interface     = "virtio"
  disk_cache         = "unsafe"
  format             = "qcow2"
  headless           = false
  use_default_display = false
  # ARM specific settings
  qemu_binary        = "qemu-system-aarch64"
  accelerator        = "hvf" # Use HVF on macOS arm64
  display            = "cocoa"
  machine_type       = "virt"
  cpu_model          = "host"
  efi_boot           = true
  efi_firmware_code  = "/opt/homebrew/share/qemu/edk2-aarch64-code.fd"
  efi_firmware_vars  = "/opt/homebrew/share/qemu/edk2-arm-vars.fd"
  qemuargs = [
    ["-device", "virtio-gpu-pci"],
    ["-device", "qemu-xhci"],
    ["-device", "driver=usb-kbd"],
    ["-device", "virtio-serial"],
    ["-chardev", "socket,name=org.qemu.guest_agent.0,id=org.qemu.guest_agent,server=on,wait=off"],
    ["-device", "virtserialport,chardev=org.qemu.guest_agent,name=org.qemu.guest_agent.0"],
    ["-serial", "file:deb_debug.log"]
  ]
}

# --- UTM ---
source "vagrant" "utm" {
  source_path  = var.base_box == null ? "dummy" : var.base_box
  box_version  = var.base_box_version == null ? "0" : var.base_box_version
  provider     = "utm"
  template     = "${path.root}/Vagrantfile.template"
  skip_add     = false
  add_force    = true
  communicator = "ssh"
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
  ssh_read_write_timeout = "1m"
}

source "utm-iso" "arm64" {
  iso_url            = local.iso_url == null ? "dummy" : local.iso_url
  iso_checksum       = local.iso_checksum
  http_content       = local.http_content_dynamic
  boot_command       = [ for cmd in var.boot_command_arm64 : cmd == "<NET_IFACE> " ? "netcfg/choose_interface=eth1 " : cmd ]
  boot_wait          = var.boot_wait
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "20m"
  ssh_read_write_timeout = "1m"
  output_directory   = "output-utm-arm64"
  shutdown_command   = var.shutdown_command
  cpus               = var.cpus
  memory             = var.memory
  disk_size          = var.disk_size
  hard_drive_interface = "virtio"
  iso_interface      = "usb"
  guest_additions_mode = "disable"
  #UTM specific
  uefi_boot          = true
  hypervisor         = true
  vm_backend         = "qemu"
  vm_arch            = "aarch64"
  display_hardware_type = "virtio-gpu-pci"
  disable_vnc        = false
  boot_nopause       = true
  display_nopause    = true
  export_nopause     = true
  keep_registered    = false
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
    "source.utm-iso.arm64",
    # BOX
    "source.vagrant.virtualbox",
    "source.vagrant.vmware",
    "source.vagrant.libvirt",
    "source.vagrant.utm"
  ]

  # Provisioning steps (common logic)
  provisioner "shell" {
    # Wait for SSH to be ready after OS install
    pause_after = "5s"
    inline = [
        "echo 'SSH is up. Starting provisioning...'"
    ]
  }

  # --- SSHD ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/common/sshd.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- Bootloader config ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/common/bootloader.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  # --- OS specific-version provisioning ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = length(var.provision_version_scripts) > 0 ? [for script_path in var.provision_version_scripts : "${script_path}"] : ["${path.root}/scripts/common/noop.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  # --- OS base provisioning ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = length(var.provision_scripts) > 0 ? [for script_path in var.provision_scripts : "${path.root}/scripts/${script_path}"] : ["${path.root}/scripts/common/noop.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- Box customization ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = length(var.box_provision_scripts) > 0 ? [for script_path in var.box_provision_scripts : "${script_path}"] : ["${path.root}/scripts/common/noop.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  # --- Vagrant user config ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/common/vagrant.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  # --- Force reboot ---
  provisioner "shell" {
    pause_before = "5s"
    pause_after = "5s"
    inline = [
      "echo 'Rebooting in background...'",
      "nohup ${var.reboot_command}  && sleep 100"
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
    pause_before = "5s"
    pause_after = "5s"
    inline = [
      "echo 'Rebooting in background...'",
      "nohup ${var.reboot_command} && sleep 100"
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
    only = ["qemu.amd64", "qemu.arm64", "vagrant.libvirt", "utm-iso.arm64"]
    execute_command = var.execute_command
    environment_vars = [
      "PACKER_BUILDER_TYPE=${source.type}"
    ]
    scripts = ["${path.root}/scripts/common/guest_tools_qemu.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- OS base cleanup ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = length(var.cleanup_scripts) > 0 ? [for script_path in var.cleanup_scripts : "${path.root}/scripts/${script_path}"] : ["${path.root}/scripts/common/noop.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }

  # --- Common cleanup ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/common/cleanup.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
   # --- Minimize box size ---
  provisioner "shell" {
    execute_command = var.execute_command
    scripts = ["${path.root}/scripts/common/wipe.sh"]
    expect_disconnect = true
    timeout         = "30m"
  }
  
  # --- 5. Post-Processing ---
  # -----------------------
  # VirtualBox
  # -----------------------
  post-processor "vagrant" {
    only     = ["virtualbox-iso.amd64", "virtualbox-iso.arm64"]
    output = "${var.box_name}-${var.build_arch}-${var.box_version}-virtualbox.box"
    compression_level    = 9
    keep_input_artifact  = false
    vagrantfile_template = (length(regexall("alpine", lower(var.box_name))) > 0 && var.build_arch == "arm64") ? "${path.root}/vagrant/vagrantfile-rsync" : null
  }
  
  post-processor "shell-local" {
    only   = ["vagrant.virtualbox"]
    inline = [
      "mv output-virtualbox/package.box ${var.box_name}-${var.build_arch}-${var.box_version}-virtualbox.box"
    ]
  }
  
  # -----------------------
  # VMware (Desktop/Fusion/Workstation)
  # -----------------------
  post-processor "vagrant" {
    only     = ["vmware-iso.amd64", "vmware-iso.arm64"]
    output = "${var.box_name}-${var.build_arch}-${var.box_version}-vmware_desktop.box"
    compression_level    = 9
    keep_input_artifact  = false
    vagrantfile_template = split("-", var.box_name)[0] == "alpine" ? "${path.root}/vagrant/vagrantfile-rsync" : null
  }
  
  post-processor "shell-local" {
    only   = ["vagrant.vmware"]
    inline = [
      "mv output-vmware/package.box ${var.box_name}-${var.build_arch}-${var.box_version}-vmware_desktop.box"
    ]
  }
  
  # -----------------------
  # QEMU / Libvirt
  # -----------------------
  # post-processors (plural) creates a sequential pipeline
  post-processors {
    post-processor "vagrant" {
      only                = ["qemu.amd64", "qemu.arm64"]
      output              = "${var.box_name}-${var.build_arch}-${var.box_version}-libvirt.box"
      compression_level   = 9
      keep_input_artifact = false
      vagrantfile_template = (var.build_arch == "arm64") ? "${path.root}/vagrant/vagrantfile-rsync" : null
    }

    # Change the provider to qemu
    post-processor "shell-local" {
      only   = ["qemu.arm64"]
      inline = [
        "mv ${var.box_name}-${var.build_arch}-${var.box_version}-libvirt.box ${var.box_name}-${var.build_arch}-${var.box_version}-qemu.box"
      ]
    }
  }
  
  post-processor "shell-local" {
    only   = ["vagrant.libvirt"]
    inline = [
      "mv output-libvirt/package.box ${var.box_name}-${var.build_arch}-${var.box_version}-libvirt.box"
    ]
  }
  
  # -----------------------
  # UTM
  # -----------------------
  post-processor "utm-vagrant" {
    only = ["utm-iso.arm64"]
    output = "${var.box_name}-${var.build_arch}-${var.box_version}-utm.box"
    compression_level    = 9
    keep_input_artifact  = false
    vagrantfile_template = split("-", var.box_name)[0] == "rocky" ? "${path.root}/vagrant/vagrantfile-utm-rhel" : "${path.root}/vagrant/vagrantfile-utm"
  }
  
  post-processor "shell-local" {
    only   = ["vagrant.utm"]
    inline = [
      "mv output-utm/package.box ${var.box_name}-${var.build_arch}-${var.box_version}-utm.box"
    ]
  }
}
