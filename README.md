[![Build from Box](https://github.com/rreye/packer-vagrant-boxes/actions/workflows/build_from_box.yml/badge.svg)](https://github.com/rreye/packer-vagrant-boxes/actions/workflows/build_from_box.yml)
[![Build from ISO](https://github.com/rreye/packer-vagrant-boxes/actions/workflows/build_from_iso.yml/badge.svg)](https://github.com/rreye/packer-vagrant-boxes/actions/workflows/build_from_iso.yml)

# Packer Vagrant Box Factory (ARM64 & AMD64)

This repository contains Packer templates to build Vagrant boxes for both **`arm64` (aarch64 / Apple Silicon)** and **`amd64` (x86_64)** architectures.

It supports two distinct build pipelines:
1.  **Customize from Base Box:** (Fast) Takes an existing box from Vagrant Cloud (e.g., `generic/ubuntu2404`) and provisions it.
2.  **Build from ISO:** (Slow) Builds a box from scratch using an OS installer ISO and an unattended installation (e.g., Ubuntu Autoinstall, Rocky Kickstart).

All builds are automated using GitHub Actions and refactored to use generic base Packer templates.

## 🏗️ Repository Structure

This repository uses a refactored structure to avoid code duplication.

* `packer/base_from_box.pkr.hcl`: The master Packer template for customizing existing Vagrant boxes.
* `packer/base_from_iso.pkr.hcl`: The master Packer template for building new boxes from an ISO.
* `packer/vagrantfile.template`: A `Vagrantfile` template used by the `base_from_box` builder.
* `ubuntu-24.04/` (etc.): Directories for boxes built **from a base box**.
    * `box.auto.pkrvars.hcl`: Defines *which* base box to use and *which* scripts to run.
    * `scripts/`: Provisioning scripts.
* `ubuntu-24.04-iso/` (etc.): Directories for boxes built **from an ISO**.
    * `box.auto.pkrvars.hcl`: Defines *which* ISO to use, `boot_command`s, `ssh_username`, etc.
    * `http/`: Unattended installation files (e.g., `user-data`, `ks.cfg`).
    * `scripts/`: Provisioning scripts.

---

## 🚀 How to Build a Box

There are two separate workflows. Choose the one that matches your goal.

### Method 1: Build from an existing Box (Fast)

Use this to apply custom provisioning to an existing Vagrant Cloud box (like `generic/ubuntu2404`).

1.  Go to the **"Actions"** tab.
2.  In the left sidebar, click on the **"🚧 Build Vagrant Box (from Box)"** workflow.
3.  Click the **"Run workflow"** dropdown button.
4.  Select the **`box_name`** (e.g., `ubuntu-24.04`).
5.  Select the **`architecture`** (e.g., `arm64` or `amd64`).
6.  Select the **`provider`** (e.g., `vagrant-vbox` or `all`).
7.  Click the green **"Run workflow"** button.

### Method 2: Build from an ISO (Slow)

Use this to create a new box from an OS installer ISO.

1.  Go to the **"Actions"** tab.
2.  In the left sidebar, click on the **"🚧 Build Vagrant Box (from ISO)"** workflow.
3.  Click the **"Run workflow"** dropdown button.
4.  Select the **`box_name`** (e.g., `ubuntu-24.04-iso`).
5.  Select the **`architecture`** (e.g., `arm64` or `amd64`).
6.  Select the **`provider`** (e.g., `virtualbox-iso` or `all`).
7.  Click the green **"Run workflow"** button.

### Downloading the Box

After a workflow is complete, you can download your `.box` file from the **"Artifacts"** section on that workflow's summary page. Artifacts are automatically deleted after 14 days.

---

## ✨ How to Add a New Box

### Adding a new "Build from Box" (e.g., Debian 12)

1.  Create a new folder: `debian-12/`
2.  Create `debian-12/scripts/` and add your provisioning scripts (e.g., `provision.sh`).
3.  Create `debian-12/box.auto.pkrvars.hcl` with its variables:
    ```hcl
    // File: debian-12/box.auto.pkrvars.hcl
    box_name         = "debian-12"
    box_version      = "1.0.0"
    base_box         = "generic/debian12"
    base_box_version = ">= 4.3.0"
    
    provision_scripts = [
      "scripts/provision.sh"
    ]
    ```
4.  Edit `.github/workflows/build_from_box.yml` and add `debian-12` to the `options` list for the `box_name` input.

### Adding a new "Build from ISO" (e.g., Fedora 40)

1.  Create a new folder: `fedora-40-iso/`
2.  Create `fedora-40-iso/http/` and add your unattended install files (e.g., `ks.cfg`).
3.  Create `fedora-40-iso/scripts/` and add your provisioning scripts (e.g., `provision.sh`).
4.  Create `fedora-40-iso/box.auto.pkrvars.hcl` with all ISO-specific variables:
    ```hcl
    // File: fedora-40-iso/box.auto.pkrvars.hcl
    box_name    = "fedora-40"
    box_version = "1.0.0"

    guest_os_type_vbox   = "Fedora_64"
    guest_os_type_vmware_amd64 = "fedora-64"
    # ... etc ...

    iso_url_amd64      = "https://.../Fedora-Server-40-x86_64.iso"
    iso_checksum_amd64 = "sha256:..."
    iso_url_arm64      = "https://.../Fedora-Server-40-aarch64.iso"
    iso_checksum_arm64 = "sha256:..."

    http_directory = "http"
    boot_command   = [
      "<tab>",
      " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
      "<enter>"
    ]
    
    ssh_username = "vagrant"
    ssh_password = "vagrant"
    shutdown_command = "echo 'vagrant' | sudo -S /sbin/halt -h -p"

    provision_scripts = [
      "scripts/provision.sh"
    ]
    ```
5.  Edit `.github/workflows/build_from_iso.yml` and add `fedora-40-iso` to the `options` list for the `box_name` input.

## 📜 License

This project is licensed under the MIT License.
