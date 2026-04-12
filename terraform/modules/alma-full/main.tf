terraform {
  required_version = ">= 1.14.7"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "sirius" {
  name          = "sirius"
  vm_id         = 101
  node_name     = "lab"
  scsi_hardware = "virtio-scsi-single"
  machine       = "q35"
  bios          = "ovmf"
  description   = "Jumphost"
  tags          = ["jumphost", "terraform"]

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  cdrom {
    # file_id = "local:iso/AlmaLinux-10.1-x86_64-dvd.iso"
    file_id = "none"

  }

  operating_system {
    type = "l26"
  }

  memory {
    dedicated = 3072
  }

  #  efi_disk {
  #    datastore_id = var.datastore_id
  #    type         = "4m"
  #  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    iothread     = true
    size         = 50
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.0.7/24"
        gateway = "10.0.0.1"
      }

    }

    user_account {
      username = "astronuat"
    }
  }

  # LAN
  network_device {
    bridge = "vmbr1"
  }

  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = "virtio"
  }

}

