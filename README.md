# Packer Vagrant Box Factory (ARM64 & AMD64)

This repository contains Packer templates to build Vagrant boxes for both **`arm64` (aarch64 / Apple Silicon)** and **`amd64` (x86_64)** architectures.

It provides two distinct build pipelines, organized by build type:
1.  **Customize from Base Box:** (Fast) Takes an existing box from Vagrant Cloud (e.g., `generic/ubuntu2404`) and provisions it.
2.  **Build from ISO:** (Slow) Builds a box from scratch using an OS installer ISO and an unattended installation.

All builds are executed locally using the `packer` CLI and a master Packer template.

## 🏗️ Repository Structure

This repository uses a refactored structure to separate build types and keep templates DRY (Don't Repeat Yourself).

*   `os_configs/`
    *   `<os_name>/` (e.g., `ubuntu`, `alpine`)
        *   `<os_version>/` (e.g., `24.04`, `3.20`)
            *   `box/`: Files for customizing an existing Vagrant box.
                *   `box.pkrvars.hcl`: Defines the base box and provisioning scripts.
                *   `scripts/`: Custom provisioning scripts for this OS.
            *   `iso/`: Files for building a box from an installer ISO.
                *   `common.pkrvars.hcl`: Defines common variables (e.g., guest OS type, boot commands).
                *   `versions/`: Contains version-specific ISO details (URLs, checksums).
                *   `http/`: Unattended installation files (e.g., `user-data`, `ks.cfg`).
                *   `scripts/`: Custom provisioning scripts for this OS.
*   `scripts/`:
    *   `common/`: Common provisioning scripts shared across all builds (e.g., `vagrant.sh`, `sshd.sh`).
*   `template.pkr.hcl`: The master Packer template used for all builds.
*   `Vagrantfile.template`: A template for the `Vagrantfile` inside the generated box.

---

## 🛠️ Supported Providers & Architectures

The following table summarizes the supported combinations of providers, architectures, and build methods:

| Provider | Build from ISO (`amd64`) | Build from ISO (`arm64`) | Customize from Box (Both) |
| :--- | :---: | :---: | :---: |
| **VirtualBox** | ✅ (`virtualbox-iso.amd64`) | ✅ (`virtualbox-iso.arm64`) | ✅ (`vagrant.virtualbox`) |
| **VMware** | ✅ (`vmware-iso.amd64`) | ✅ (`vmware-iso.arm64`) | ✅ (`vagrant.vmware`) |
| **QEMU** | ✅ (`qemu.amd64`) | ✅ (`qemu.arm64`) | ✅ (`vagrant.qemu`) |
| **UTM** | ❌ | ✅ (`utm-iso.arm64`) | ✅ (`vagrant.utm`) |
| **Libvirt** | ❌* | ❌* | ✅ (`vagrant.libvirt`) |

*\* Note: Boxes for Libvirt can be generated from the `qemu` ISO builds, as the post-processor packages the QEMU image into a libvirt-compatible Vagrant box.*

---

## 🚀 How to Build a Box

First, initialize Packer to download the required plugins:

```bash
packer init template.pkr.hcl
```

There are two separate methods to build a box. Choose the one that matches your goal.

### Method 1: Customize an Existing Box (Fast)

Use this to apply custom provisioning to an existing Vagrant Cloud box.

Run the `packer build` command, specifying the appropriate builder (`vagrant.<provider>`) and variable files.

For example, to build an `ubuntu-24.04` box for `amd64` using `virtualbox`:

```bash
packer build \
  -only=vagrant.virtualbox \
  -var="build_arch=amd64" \
  -var-file="os_configs/ubuntu/24.04/iso/common.pkrvars.hcl" \
  -var-file="os_configs/ubuntu/24.04/box/box.pkrvars.hcl" \
  template.pkr.hcl
```

*Note: You may need to provide variables like `execute_command` and `shutdown_command` depending on your OS configuration.*

Available builders for customizing boxes are: `vagrant.virtualbox`, `vagrant.vmware`, `vagrant.libvirt`, `vagrant.qemu`, and `vagrant.utm`.

### Method 2: Build from an ISO (Slow)

Use this to create a new box from an OS installer ISO.

Run the `packer build` command, specifying the appropriate builder (`<provider>.amd64` or `<provider>.arm64`) and the ISO variable files.

For example, to build an `ubuntu-24.04` box from ISO for `amd64` using `qemu`:

```bash
packer build \
  -only=qemu.amd64 \
  -var="build_arch=amd64" \
  -var-file="os_configs/ubuntu/24.04/iso/common.pkrvars.hcl" \
  -var-file="os_configs/ubuntu/24.04/iso/versions/24.04.3.pkrvars.hcl" \
  template.pkr.hcl
```

Available ISO builders include: `virtualbox-iso.amd64`, `virtualbox-iso.arm64`, `vmware-iso.amd64`, `vmware-iso.arm64`, `qemu.amd64`, `qemu.arm64`, and `utm-iso.arm64`.

### Retrieving the Box

Once the build is successfully completed, the output `.box` file will be generated in your current working directory (e.g., `ubuntu-24.04-amd64-24.04.3-qemu.box`).

---

## ✨ How to Add a New Box

### Adding a "Customize from Box" Configuration (e.g., Debian 12)

1.  Create the directory structure: `os_configs/debian/12/box/scripts/`.
2.  Add your custom provisioning scripts in the `scripts/` directory (e.g., `provision.sh`).
3.  Create the variable definitions file: `os_configs/debian/12/box/box.pkrvars.hcl`.
    ```hcl
    // File: os_configs/debian/12/box/box.pkrvars.hcl
    base_box         = "generic/debian12"
    base_box_version = ">= 4.3.0"
    
    box_provision_scripts = [
      "os_configs/debian/12/box/scripts/provision.sh"
    ]
    ```

### Adding a "Build from ISO" Configuration (e.g., Fedora 40)

1.  Create the directory structure: `os_configs/fedora/40/iso/http/` and `os_configs/fedora/40/iso/scripts/`.
2.  Place unattended install files (e.g., `ks.cfg`) in the `http/` directory.
3.  Add provisioning scripts in the `scripts/` directory.
4.  Create the common variables file: `os_configs/fedora/40/iso/common.pkrvars.hcl`.
    ```hcl
    // File: os_configs/fedora/40/iso/common.pkrvars.hcl
    box_name           = "fedora-40"
    guest_os_type_vbox = "Fedora_64"
    # ... other common variables ...

    boot_command = [
      "<tab>",
      " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
      "<enter>"
    ]
    ```
5.  Create a version-specific file, e.g., `os_configs/fedora/40/iso/versions/40.20240422.pkrvars.hcl`.
    ```hcl
    // File: os_configs/fedora/40/iso/versions/40.20240422.pkrvars.hcl
    box_version        = "1.0.0"
    iso_url_amd64      = "https://.../Fedora-Server-40-1.14-x86_64.iso"
    iso_checksum_amd64 = "sha256:..."
    # ... other version-specific variables ...
    ```

## 📜 License

This project is licensed under the MIT License.
