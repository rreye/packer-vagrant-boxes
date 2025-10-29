[![Build Vagrant Boxes](https://github.com/rreye/packer-vagrant-boxes/actions/workflows/build-box.yml/badge.svg)](https://github.com/rreye/packer-vagrant-boxes/actions/workflows/build-box.yml)

# Packer Vagrant Box Factory (ARM64 & AMD64)

This repository contains Packer templates to build Vagrant boxes for both **`arm64` (aarch64 / Apple Silicon)** and **`amd64` (x86_64)** architectures.

The entire build process is automated using a single, reusable GitHub Actions workflow. The workflow dynamically selects the correct build runner based on your choice:
* **`arm64`**: Builds on a `macos-latest` runner.
* **`amd64`**: Builds on an `ubuntu-latest` runner.

## 📦 Available Boxes & Providers

This factory is set up to build the following configurations. Adding new boxes is as simple as creating a new directory and a variables file.

| Operating System | Base Box | Target Providers |
| :--- | :--- | :--- |
| **Ubuntu 24.04** | `generic/ubuntu2404` | VirtualBox, VMware, QEMU/Libvirt |
| **Alpine 3.18** | `generic/alpine318` | VirtualBox, VMware, QEMU/Libvirt |
| *(add more here)* | | |

## 🚀 How to Build a Box

All images are built using a manual workflow. You do not need Packer or Vagrant installed on your local machine.

1.  Go to the **"Actions"** tab in this repository.
2.  In the left sidebar, click on the **"🚧 Build Vagrant Box"** workflow.
3.  Click the **"Run workflow"** dropdown button on the right. 
4.  Select the **`box_name`** (the operating system) you want to build (e.g., `ubuntu-24.04`).
5.  Select the **`architecture`** you want to build for (e.g., `arm64` or `amd64`).
6.  Select the **`provider`** you want to build for (e.g., `vagrant-vbox` or `all` for all providers).
7.  Click the green **"Run workflow"** button.

The action will run (it may take 20-60 minutes). Once complete, you can download your `.box` file from the **"Artifacts"** section on that workflow's summary page.

**Note:** The artifact name will include the architecture (e.g., `box-ubuntu-24.04-vagrant-vbox-arm64`). Artifacts are automatically deleted after 7 days.

## 🏗️ Repository Structure

This repository is refactored to be DRY (Don't Repeat Yourself) by using a central Packer "base" template.

* `packer/base.pkr.hcl`: This is the **master Packer template**. It contains all the build logic (the 3 Vagrant builders, the provisioning block, etc.). It is 100% generic and receives the architecture as a variable (`build_arch`).

* `ubuntu-24.04/box.auto.pkrvars.hcl`: Each box directory (like `ubuntu-24.04`, `alpine-3.18`, etc.) contains this file. It defines the specific **variables** for that build (the box name, the base box from Vagrant Cloud, and the list of scripts to run).

* `ubuntu-24.04/scripts/`: This folder contains the actual provisioning scripts (`provision.sh`, `cleanup.sh`, etc.) that are specific to that operating system.

## ✨ How to Add a New Box (e.g., Rocky 9)

1.  Create a new root folder, e.g., `rocky-9/`.
2.  Inside `rocky-9/`, create a `scripts/` folder and add your provisioning scripts (e.g., `provision.sh` with `dnf` commands, `cleanup.sh`, etc.).
3.  Inside `rocky-9/`, create a `box.auto.pkrvars.hcl` file and define its variables:

    ```hcl
    // File: rocky-9/box.auto.pkrvars.hcl
    
    // Note: box_name is arch-independent, the arch is added by the build template
    box_name         = "rocky-9"
    box_version      = "1.0.0"
    base_box         = "generic/rocky9" // This is a multi-arch box
    base_box_version = ">= 4.3.0"
    
    provision_scripts = [
      "scripts/provision.sh", // Your 'dnf' script
      "scripts/vagrant.sh",
      "scripts/cleanup.sh"
    ]
    ```

4.  Finally, edit `.github/workflows/build-box.yml` and add `rocky-9` to the `options` list for the `box_name` input.

## 📜 License

This project is licensed under the MIT License.
