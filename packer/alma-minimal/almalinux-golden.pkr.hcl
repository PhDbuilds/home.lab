# -------------------------------------------------------------------
# AlmaLinux 9 Golden Image
# Builds a hardened base template on Proxmox via kickstart
#
# Usage:
#   packer init .
#   packer validate .
#   packer build .
#
# Prerequisites:
#   - AlmaLinux 9 minimal ISO uploaded to Proxmox storage
#   - VAULT_ADDR set and authenticated (vault login)
#
# Docs:
#   Plugin:    https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox/latest/components/builder/iso
#   Kickstart: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/automatically_installing_rhel/kickstart-commands-and-options-reference_rhel-installer
# -------------------------------------------------------------------

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# ─── Secrets from Vault ───────────────────────────────────────

locals {
  proxmox_url         = vault("secret/data/packer", "pkr_var_proxmox_url")
  proxmox_username    = vault("secret/data/packer", "pkr_var_proxmox_username")
  proxmox_token       = vault("secret/data/packer", "pkr_var_proxmox_token")
  ssh_public_key_path = vault("secret/data/packer", "pkr_var_ssh_public_key_path")
}

# ─── Variables ────────────────────────────────────────────────

variable "proxmox_node" {
  type    = string
  default = "lab"
}

variable "iso_file" {
  type        = string
  default     = "local:iso/AlmaLinux-9-latest-x86_64-minimal.iso"
  description = "Path to the AlmaLinux 9 (minimal) ISO in Proxmox storage"
}

variable "vm_id" {
  type    = number
  default = 9000
}

variable "storage_pool" {
  type    = string
  default = "local-lvm"
}

# ─── Source ───────────────────────────────────────────────────

source "proxmox-iso" "almalinux-golden" {
  # Proxmox connection
  proxmox_url              = local.proxmox_url
  username                 = local.proxmox_username
  token                    = local.proxmox_token
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  # VM settings
  vm_id                = var.vm_id
  vm_name              = "almalinux9-golden"
  machine              = "q35"
  bios = "ovmf"
  efi_config {
    efi_storage_pool  = var.storage_pool
    pre_enrolled_keys = false
  }
  template_name        = "almalinux9-golden"
  template_description = "AlmaLinux 9 Golden Image — built with Packer on ${timestamp()}"
  os                   = "l26"
  qemu_agent           = true

  # Hardware
  cores  = 2
  memory = 4096
  cpu_type = "host"

  scsi_controller = "virtio-scsi-single"

  disks {
    type         = "scsi"
    disk_size    = "20G"
    storage_pool = var.storage_pool
    io_thread     = true
  }

  # Build on vmbr0 so the VM has internet for package installs
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # ISO — boot_iso block replaces the deprecated top-level iso_file param
  # Ref: https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox/latest/components/builder/iso
  boot_iso {
    iso_file     = var.iso_file
    unmount      = true
    iso_checksum = "none"
  }

  # UEFI/OVMF GRUB: press 'e' to edit the selected entry, navigate to end of
  # the linuxefi line, append the kickstart URL, then Ctrl+X to boot.
  boot_command = [
    "<wait><up><wait3>",
    "e<wait2>",
    "<down><down><end><wait>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]
  boot_wait = "20s"

  # Packer serves the kickstart file from this directory
  http_directory = "http"

  # SSH — packer connects with these creds after kickstart completes
  ssh_username = "root"
  ssh_password = "packer"
  ssh_timeout  = "20m"

  # Cloud-init drive for cloned VMs
  cloud_init              = true
  cloud_init_storage_pool = var.storage_pool
}

# ─── Build ────────────────────────────────────────────────────

build {
  sources = ["source.proxmox-iso.almalinux-golden"]

  # Copy your SSH public key for the ansible user
  provisioner "file" {
    source      = local.ssh_public_key_path
    destination = "/tmp/ansible_authorized_key.pub"
  }

  # Run the provisioning script
  provisioner "shell" {
    script          = "scripts/provision.sh"
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} bash {{ .Path }}"
  }
}
