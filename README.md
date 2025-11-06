[![Build from Box](https://github.com/rreye/packer-vagrant-boxes/actions/workflows/build_from_box.yml/badge.svg)](https://github.com/rreye/packer-vagrant-boxes/actions/workflows/build_from_box.yml)
[![Build from ISO](https://github.com/rreye/packer-vagrant-boxes/actions/workflows/build_from_iso.yml/badge.svg)](https://github.com/rreye/packer-vagrant-boxes/actions/workflows/build_from_iso.yml)

# Packer Vagrant Box Factory (ARM64 & AMD64)

This repository contains Packer templates to build Vagrant boxes for both **`arm64` (aarch64 / Apple Silicon)** and **`amd64` (x86_64)** architectures.

It provides two distinct build pipelines, organized by build type:
1.  **Customize from Base Box:** (Fast) Takes an existing box from Vagrant Cloud (e.g., `generic/ubuntu2404`) and provisions it.
2.  **Build from ISO:** (Slow) Builds a box from scratch using an OS installer ISO and an unattended installation.

All builds are automated using GitHub Actions and a master Packer template.

## 🏗️ Repository Structure

This repository uses a refactored structure to separate build types and keep templates DRY (Don't Repeat Yourself).

*   `.github/`
    *   `workflows/`
        *   `build_from_box.yml`: Workflow for customizing boxes.
        *   `build_from_iso.yml`: Workflow for building boxes from scratch.
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

## 🚀 How to Build a Box

There are two separate workflows. Choose the one that matches your goal.

### Method 1: Customize an Existing Box (Fast)

Use this to apply custom provisioning to an existing Vagrant Cloud box.

1.  Go to the **"Actions"** tab in the repository.
2.  In the left sidebar, click on the **"Build Vagrant Boxes (from other boxes)"** workflow.
3.  Click the **"Run workflow"** dropdown button.
4.  Select the **`distro`** you want to build (e.g., `ubuntu-24.04`). This must match a corresponding directory in `os_configs/`.
5.  Select the **`architecture`** (`amd64` or `arm64`).
6.  Select the **`provider`** (`virtualbox`, `vmware`, or `libvirt`).
7.  Click the green **"Run workflow"** button.

### Method 2: Build from an ISO (Slow)

Use this to create a new box from an OS installer ISO.

1.  Go to the **"Actions"** tab.
2.  In the left sidebar, click on the **"Build Vagrant Boxes (from ISO)"** workflow.
3.  Click the **"Run workflow"** dropdown button.
4.  Select the **`distro`** (e.g., `ubuntu-24.04`, `rocky-9`). This must match a directory in `os_configs/`.
5.  Optionally, specify the **`iso_version`** to build (e.g., `24.04.3`). If left empty, the latest version will be used.
6.  Select the **`architecture`** (`amd64` or `arm64`).
7.  Select the **`provider`** (`virtualbox-iso`, `vmware-iso`, or `qemu`).
8.  Click the green **"Run workflow"** button.

### Downloading the Box

After a workflow is complete, you can download your `.box` file from the **"Artifacts"** section on that workflow's summary page. Artifacts are automatically deleted after 14 days.

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
4.  Go to `.github/workflows/build_from_box.yml` and add `debian-12` to the `options` list for the `distro` input.

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
6.  Go to `.github/workflows/build_from_iso.yml` and add `fedora-40` to the `options` list for the `distro` input.

## 📜 License

This project is licensed under the MIT License.
